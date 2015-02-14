# Sheet Model
class Sheet < ActiveRecord::Base
  include Deduplicatable
  include Relatable
  include Taggable
  include Licensable
  include Instrumentable
  include Visible
  include Flaggable
  include Favoritable

  PDF_PREVIEW_DEFAULT_URL = 'nil' # TODO: point to special Missing file route
  PDF_DEFAULT_URL = 'nil'
  EXPIRATION_TIME = 30
  MIN_PRICE = 99
  MAX_PRICE = 999_99
  MAX_FILESIZE = 20
  PRICE_VALUE_VALIDATION_MESSAGE = 'Price must be either $0 or between $0.99 - $999.99'
  INVALID_ASSETS_MESSAGE = 'Sheet supporting files invalid'
  HIT_QUOTA_MESSAGE = 'You have hit the number of free sheets you can upload. Upgrade your membership to Plus or Pro to upload more free sheets on SheetHub.'

  belongs_to :user
  before_create :record_publisher_status
  before_save :validate_free_sheet_quota

  acts_as_paranoid
  searchkick word_start: [:name]
  extend FriendlyId
  friendly_id :sheet_slug, use: :slugged

  validate :validate_price
  validates :title, presence: true

  scope :best_sellers, -> { is_public.order(price_cents: :desc) }
  scope :community_favorites, -> { is_public.order(cached_votes_up: :desc) }

  enum difficulty: %w( beginner intermediate advanced )

  has_attached_file :pdf,
                    styles: {
                      preview: { geometry: '', format: :png }
                    },
                    processors: [:preview],
                    hash_secret: Rails.application.secrets.sheet_hash_secret,
                    default_url: PDF_DEFAULT_URL,
                    preserve_files: 'true',
                    s3_permissions: {
                      preview: :public_read,
                      original: :private
                    }
  validates_attachment_content_type :pdf,
                                    content_type: ['application/pdf']
  validates_attachment_size :pdf, in: 0.megabytes..MAX_FILESIZE.megabytes
  validates :pdf, presence: true
  before_save :extract_number_of_pages

  def extract_number_of_pages
    return unless pdf?
    tempfile = pdf.queued_for_write[:original]
    unless tempfile.nil?
      pdf = MiniMagick::Image.open(tempfile.path)
      self.pages = pdf.pages.size
    end
  end

  has_many :assets, dependent: :destroy
  accepts_nested_attributes_for :assets
  validates_associated :assets,
                       on: [:create, :update],
                       message: INVALID_ASSETS_MESSAGE

  auto_html_for :description do
    html_escape
    image
    youtube(width: 345, height: 240, autoplay: false)
    vimeo(width: 345, height: 240)
    soundcloud(width: 345, height: 165, autoplay: false)
    link target: '_blank', rel: 'nofollow'
    simple_format
  end

  def self.cached_best_sellers
    Rails.cache.fetch('best_sellers', expires_in: 1.day) do
      Sheet.includes(:user).best_sellers
    end
  end

  def self.cached_community_favorites
    Rails.cache.fetch('community_favorites', expires_in: 1.day) do
      Sheet.includes(:user).community_favorites
    end
  end

  def purchased_by?(user)
    return false unless user
    user.purchased?(id)
  end

  def uploaded_by?(usr)
    return false unless usr
    user.id == usr.id
  end

  def completed_orders
    Order.where(sheet_id: id, status: Order.statuses[:completed])
  end

  def total_sales
    completed_orders.inject(0) { |total, order| total + order.amount }
  end

  def total_earnings
    completed_orders.inject(0) { |total, order| total + order.royalty }
  end

  def average_sales
    completed_orders.average(:amount_cents).to_f / 100
  end

  def maximum_sale
    completed_orders.maximum(:amount_cents).to_f / 100
  end

  def price
    price_cents.to_f / 100
  end

  def price=(val)
    write_attribute :price_cents, (val.to_f * 100).to_i
  end

  def royalty
    (user.royalty_percentage * price).round(2)
  end

  def royalty_cents
    (user.royalty_percentage * price_cents).round(0)
  end

  def commission
    ((1 - user.royalty_percentage) * price).round(2)
  end

  def commission_cents
    ((1 - user.royalty_percentage) * price_cents).round(0)
  end

  def free?
    price_cents.zero?
  end

  def sheet_slug
    [
      :title,
      [:title, user.username]
    ]
  end

  def restore
    restore_tags
    Sheet.restore(self, recursive: true)
  end

  def pdf_preview?
    pdf_preview_url.present? && pdf_preview_url != PDF_PREVIEW_DEFAULT_URL
  end

  def pdf_preview_url
    pdf.url(:preview) || PDF_PREVIEW_DEFAULT_URL
  end

  def pdf_download_url
    pdf.expiring_url(EXPIRATION_TIME)
  end

  # Override Soft Destroy
  def destroy
    clear_tags
    super
    SheetMailer.sheet_deleted_email(self).deliver
  end

  # Override Hard Destroy
  def really_destroy!
    super
    SheetMailer.sheet_really_deleted_email(self).deliver
  end

  protected

  def validate_free_sheet_quota
    invalid_quota = self.free? && user.hit_sheet_quota?
    errors.add(:sheet_quota, HIT_QUOTA_MESSAGE) if invalid_quota
  end

  def validate_price
    valid_price = price_cents.zero? || price_cents.in?(MIN_PRICE..MAX_PRICE)
    errors.add(:price, PRICE_VALUE_VALIDATION_MESSAGE) unless valid_price
  end

  def record_publisher_status
    user.update_attribute(:has_published, true) unless user.has_published
  end
end