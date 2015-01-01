# User model
class User < ActiveRecord::Base
  AVATAR_HASH_SECRET = 'sheethubhashsecret'
  MISSING_AVATAR_URL = 'default_avatar.png'
  EXPIRATION_TIME = 600
  BASIC_FREE_SHEET_QUOTA = 10
  PLUS_FREE_SHEET_QUOTA = 75
  PRO_FREE_SHEET_QUOTA = 250
  BASIC_ROYALTY_PERCENTAGE = 0.80
  PLUS_ROYALTY_PERCENTAGE = 0.80
  PRO_ROYALTY_PERCENTAGE = 0.85
  AVATAR_MAX_WIDTH = 300
  AVATAR_MAX_HEIGHT = 300
  INVALID_MEMBERSHIP_TYPE_MESSAGE = 'Membership type does not exist'
  MISSING_SUBSCRIPTION_OBJECT_MESSAGE = 'Error: Subscription object missing. Contact support.'

  enum membership_type: %w( basic plus pro staff )
  validates :username, presence: true, uniqueness: { case_sensitive: false }, if: :finished_registration?
  validates :billing_full_name, presence: true, if: :finished_registration?
  validates :billing_address_line_1, presence: true, if: :finished_registration?
  validates :billing_city, presence: true, if: :finished_registration?
  validates :billing_state_province, presence: true, if: :finished_registration?
  validates :billing_country, presence: true, if: :finished_registration?
  validates :billing_zipcode, presence: true, if: :finished_registration?
  validate :timezone_is_populated, if: :finished_registration?
  validates_email_format_of :email, message: 'You have an invalid email address'
  validates_email_format_of :paypal_email, message: 'You have an invalid paypal account email address', if: :has_paypal_email?
  has_many :sheets, dependent: :destroy
  has_one :subscription
  acts_as_voter
  before_save :cache_display_name
  after_save :update_mixpanel_profile

  has_attached_file :avatar,
                    convert_options: {
                      original: '-strip'
                    },
                    hash_secret: AVATAR_HASH_SECRET,
                    default_url: MISSING_AVATAR_URL
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/
  validates :avatar, dimensions: { width: AVATAR_MAX_WIDTH,
                                   height: AVATAR_MAX_HEIGHT }
  attr_accessor :remove_avatar

  # Devise modules
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :validatable, :confirmable, :lockable
  devise :omniauthable, omniauth_providers: [:facebook, :google_oauth2]

  def royalty_percentage
    return BASIC_ROYALTY_PERCENTAGE if basic?
    return PLUS_ROYALTY_PERCENTAGE if plus?
    return PRO_ROYALTY_PERCENTAGE if pro?
  end

  def self.free_sheet_quota_of(membership_type)
    m = membership_type.downcase
    raise INVALID_MEMBERSHIP_TYPE_MESSAGE unless m.in? User.membership_types.keys
    return BASIC_FREE_SHEET_QUOTA if m == 'basic'
    return PLUS_FREE_SHEET_QUOTA if m == 'plus'
    return PRO_FREE_SHEET_QUOTA if m == 'pro'
  end

  def update_membership_to(membership_type)
    m = membership_type.downcase
    raise INVALID_MEMBERSHIP_TYPE_MESSAGE unless m.in? User.membership_types.keys
    # raise MISSING_SUBSCRIPTION_OBJECT_MESSAGE unless has_subscription_for_membership(membership_type) || basic?
    update(membership_type: m, sheet_quota: User.free_sheet_quota_of(m))
  end

  def has_subscription_for_membership(membership_type)
    Subscription.find_by(user: self,
                         membership_type:Subscription.membership_types[membership_type],
                         status: Subscription.statuses[:completed]).present?
  end

  def premium_subscription
    Subscription.find_by(user: self, status: Subscription.statuses[:completed])
  end

  def completed_subscriptions
    Subscription.where(user: self, status: Subscription.statuses[:completed]).order(:updated_at)
  end

  def premium?
    plus? || pro?
  end

  def joined_at
    created_at.strftime '%B %Y'
  end

  def display_name
    cached_display_name || cache_display_name
  end

  def public_sheets
    sheets.where(visibility: Sheet.visibilities[:vpublic])
  end

  def private_sheets
    sheets.where(visibility: Sheet.visibilities[:vprivate])
  end

  def has_paypal_email?
    paypal_email.present?
  end

  def free_sheets
    sheets.where(price_cents: 0)
  end

  def remaining_sheet_quota
    sheet_quota - free_sheets.size
  end

  def hit_sheet_quota?
    free_sheets.size >= sheet_quota
  end

  def hit_sheet_quota_for_basic?
    free_sheets.size >= BASIC_FREE_SHEET_QUOTA
  end

  def sales
    Order.includes(:user).includes(:sheet).where(sheet_id: sheets.ids, status: Order.statuses[:completed])
  end

  def all_sales_data


  end

  def aggregated_sales
    result = {}
    sheets.find_each do |sheet|
      total_sales = sheet.total_sales
      result[sheet.title] = total_sales if total_sales > 0
    end
    result
  end

  def aggregated_earnings
    sheets.inject(0) { |total, sheet| total + sheet.total_earnings }
  end

  def sales_past_month
    sales.where('purchased_at >= ?', 1.month.ago.utc)
  end

  def earnings_past_month
    sales_past_month.inject(0) { |total, order| total + order.royalty }
  end

  def purchased_orders
    Order.where(user_id: id, status: Order.statuses[:completed])
  end

  def purchased?(sheet_id)
    purchased_orders.where(sheet_id: sheet_id).present?
  end

  def deleted_sheets
    Sheet.only_deleted.where(user_id: id)
  end

  def avatar_url
    if avatar.url.present? && avatar.url != MISSING_AVATAR_URL
      avatar.expiring_url(EXPIRATION_TIME, :original)
    elsif image.present?
      image
    else
      MISSING_AVATAR_URL
    end
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
      user.skip_confirmation!

      # Get normal quality picture if using omniauth-facebook
      if auth.provider == 'facebook'
        user.image = auth.info.image + '?type=large'
      else
        user.image = auth.info.image
      end
      user.save
    end
  end

  def build_display_name
    if first_name.present?
      if last_name.present?
        "#{first_name} #{last_name}"
      else
        first_name
      end
    else
      username
    end
  end

  def cache_display_name
    self.cached_display_name = build_display_name
  end

  def update_mixpanel_profile
    Analytics.update_profile(self)
  end

  def timezone_is_populated
    errors.add(:timezone, 'cannot be blank') if timezone.blank?
  end
end
