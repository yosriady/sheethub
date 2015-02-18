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
  include SoftDestroyable
  include Sluggable
  include PdfAttachable
  include AssetAttachable
  include Pricable

  HIT_QUOTA_MESSAGE = 'You have hit the number of free sheets you can upload. Upgrade your membership to Plus or Pro to upload more free sheets on SheetHub.'

  belongs_to :user
  before_create :record_publisher_status
  before_save :validate_free_sheet_quota

  searchkick word_start: [:name]
  validates :title, presence: true

  scope :best_sellers, -> { is_public.order(price_cents: :desc) }
  scope :community_favorites, -> { is_public.order(cached_votes_up: :desc) }

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

  protected

  def validate_free_sheet_quota
    invalid_quota = self.free? && user.hit_sheet_quota?
    errors.add(:sheet_quota, HIT_QUOTA_MESSAGE) if invalid_quota
  end

  def record_publisher_status
    user.update_attribute(:has_published, true) unless user.has_published
  end
end
