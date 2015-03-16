# Sheet Model
class Sheet < ActiveRecord::Base
  include Relatable
  include Taggable
  include Licensable
  include Instrumentable
  include Visible
  include Flaggable
  include Likable
  include SoftDestroyable
  include Sluggable
  include PdfAttachable
  include AssetAttachable
  include Pricable
  include Purchasable

  HIT_QUOTA_MESSAGE = 'You have hit the number of free sheets you can upload. Upgrade your membership to Plus or Pro to upload more free sheets on SheetHub.'

  belongs_to :user
  before_create :record_publisher_status
  before_save :validate_free_sheet_quota

  searchkick word_start: [:name]
  validates :title, presence: true

  scope :this_month, -> {is_public.where(created_at: 1.month.ago..Time.zone.now)}
  scope :this_week, -> {is_public.where(created_at: 1.week.ago..Time.zone.now)}
  scope :this_day, -> {is_public.where(created_at: 1.day.ago..Time.zone.now)}
  scope :best_sellers, -> { is_public.order(price_cents: :desc) }

  enum difficulty: %w( beginner intermediate advanced )

  auto_html_for :description do
    html_escape
    image
    youtube(width: 345, height: 240, autoplay: false)
    vimeo(width: 345, height: 240)
    soundcloud(width: 345, height: 165, autoplay: false)
    link target: '_blank', rel: 'nofollow'
    simple_format
  end

  def self.filter_date_enum
    ["all-time", "week", "month", "day"]
  end

  def self.sort_enum
    ["recent", "likes"]
  end

  def self.cached_best_sellers
    Rails.cache.fetch('best_sellers', expires_in: 1.day) do
      Sheet.includes(:user).best_sellers
    end
  end

  def uploaded_by?(usr)
    return false unless usr
    user.id == usr.id
  end

  protected

  def validate_free_sheet_quota
    invalid_quota = self.free? && user.hit_sheet_quota?
    errors.add(:sheet_quota, HIT_QUOTA_MESSAGE) if invalid_quota
  end

  def record_publisher_status
    user.update_attribute(:has_published, true) unless user.has_published
  end
end
