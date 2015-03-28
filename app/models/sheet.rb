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

  belongs_to :user, counter_cache: true
  before_create :record_publisher_status

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

  def self.filter(params = {})
    # TODO: cache
    sheets = Sheet.is_public
    if params[:date].present? && params[:date].in?(Sheet.filter_date_enum)
      sheets = sheets.send('this_#{params[:date]}') if params[:date] != 'all-time'
    end
    if params[:sort_by].present? && params[:sort_by].in?(Sheet.sort_enum)
      sheets = sheets.most_liked if params[:sort_by] == 'likes'
    end
    sheets = sheets.tagged_with(params[:tags].split) if params[:tags].present?
    sheets = sheets.with_any_instruments(*params[:instruments].split) if params[:instruments].present?
    sheets.page(params[:page])
  end

  def self.filter_date_enum
    ['all-time', 'week', 'month', 'day']
  end

  def self.sort_enum
    ['recent', 'likes']
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

  def out_of_stock?
    !in_stock?
  end

  def in_stock?
    free? || !limit_purchases || (limit_purchases && !limit_purchase_quantity.zero?)
  end

  protected

  def record_publisher_status
    user.update_attribute(:has_published, true) unless user.has_published
  end
end
