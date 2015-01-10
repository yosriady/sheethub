# Sheet Model
class Sheet < ActiveRecord::Base
  include Deduplicatable
  include Relatable
  include Taggable

  PDF_PREVIEW_DEFAULT_URL = 'nil' # TODO: point to special Missing file route
  PDF_DEFAULT_URL = 'nil'
  EXPIRATION_TIME = 30
  MIN_PRICE = 99
  MAX_PRICE = 999_99
  MAX_FILESIZE = 20
  MAX_NUMBER_OF_TAGS = 5
  PRICE_VALUE_VALIDATION_MESSAGE = 'Price must be either $0 or between $0.99 - $999.99'
  INVALID_ASSETS_MESSAGE = 'Sheet supporting files invalid'
  TOO_MANY_TAGS_MESSAGE = 'You have too many tags. Each sheet can have up to 5 of each: genres, composers, sources.'
  HIT_QUOTA_MESSAGE = 'You have hit the number of free sheets you can upload. Upgrade your membership to Plus or Pro to upload more free sheets on SheetHub.'

  belongs_to :user
  has_many :flags, dependent: :destroy
  before_create :record_publisher_status
  before_save :validate_free_sheet_quota

  acts_as_votable
  acts_as_paranoid
  acts_as_taggable
  acts_as_taggable_on :composers, :genres, :sources
  searchkick word_start: [:name]
  extend FriendlyId
  friendly_id :sheet_slug, use: :slugged

  validate :validate_price
  validate :validate_number_of_tags
  validates :title, presence: true
  validates :license, presence: true
  validates :visibility, presence: true
  validates :instruments, presence: true

  scope :is_public, -> { where(visibility: Sheet.visibilities[:vpublic]) }
  scope :is_private, -> { where(visibility: Sheet.visibilities[:vprivate]) }
  scope :flagged, -> { where(is_flagged: true) }
  scope :best_sellers, -> { is_public.order(price_cents: :desc) }
  scope :community_favorites, -> { is_public.order(cached_votes_up: :desc) }

  enum visibility: %w( vpublic vprivate )
  enum difficulty: %w( beginner intermediate advanced )
  enum license: %w( all_rights_reserved creative_commons cc0 public_domain licensed_arrangement)

  attr_accessor :instruments_list # For form parsing
  bitmask :instruments, as: [:others, :guitar, :piano, :bass, :mandolin, :banjo,
                             :ukulele, :violin, :flute, :harmonica, :trombone,
                             :trumpet, :clarinet, :saxophone, :viola, :oboe,
                             :cello, :bassoon, :organ, :harp, :accordion, :lute,
                             :tuba, :ocarina], null: false

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

  def verbose_license
    return 'All rights reserved' if all_rights_reserved?
    return 'Creative Commons' if creative_commons?
    return 'Creative Commons Zero' if cc0?
    return 'Public Domain' if public_domain?
    return 'Licensed' if licensed_arrangement?
  end

  def purchased_by?(user)
    return false unless user
    user.purchased?(id)
  end

  def uploaded_by?(usr)
    return false unless usr
    user.id == usr.id
  end

  def publicly_visible?
    vpublic?
  end

  def privately_visible?
    vprivate?
  end

  def visibility_string
    visibility[1..-1].titleize
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

  def favorited_by(user)
    liked_by user
    SheetMailer.sheet_favorited_email(self, user).deliver
  end

  def unfavorited_by(user)
    unliked_by user
  end

  def restore
    restore_tags
    Sheet.restore(self, recursive: true)
  end

  def clear_tags
    genres.clear
    sources.clear
    composers.clear
  end

  def restore_tags
    self.genre_list = self.cached_genres
    self.source_list = self.cached_sources
    self.composer_list = self.cached_composers
    self.save!
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

  def self.instruments_to_bitmask(instruments)
    (instruments & Sheet.values_for_instruments).map { |r| 2**Sheet.values_for_instruments.index(r) }.inject(0, :+)
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

  def composer_list=(tag_list=[])
    super
    tag_list.map!(&:downcase)
    self.cached_composers = tag_list
    self.cached_joined_tags = [instruments, genre_list, source_list, tag_list].flatten
  end

  def genre_list=(tag_list=[])
    super
    tag_list.map(&:downcase)
    self.cached_genres = tag_list
    self.cached_joined_tags = [instruments, composer_list, source_list, tag_list].flatten
  end

  def source_list=(tag_list=[])
    super
    tag_list.map(&:downcase)
    self.cached_sources = tag_list
    self.cached_joined_tags = [instruments, genre_list, composer_list, tag_list].flatten
  end

  protected

  def tags
    [genre_list, composer_list, source_list].flatten
  end

  def tag_objects
    [genres, composers, sources].flatten
  end

  # Formatting method for selectize.js usage
  def format_tags(input)
    output = ''
    input.each do |tag|
      output << "'#{tag}',"
    end
    output[0..-2] # Strip trailing comma
  end

  def validate_free_sheet_quota
    invalid_quota = self.free? && user.hit_sheet_quota?
    errors.add(:sheet_quota, HIT_QUOTA_MESSAGE) if invalid_quota
  end

  def validate_price
    valid_price = price_cents.zero? || price_cents.in?(MIN_PRICE..MAX_PRICE)
    errors.add(:price, PRICE_VALUE_VALIDATION_MESSAGE) unless valid_price
  end

  def validate_number_of_tags
    valid_number = genre_list.size <= MAX_NUMBER_OF_TAGS && source_list.size <= MAX_NUMBER_OF_TAGS && composer_list.size <= MAX_NUMBER_OF_TAGS
    errors.add(:tags, TOO_MANY_TAGS_MESSAGE) unless valid_number
  end

  def record_publisher_status
    user.update_attribute(:has_published, true) unless user.has_published
  end
end