class User < ActiveRecord::Base
  AVATAR_HASH_SECRET = "sheethubhashsecret"
  MISSING_AVATAR_URL = "/images/default_avatar.png"
  EXPIRATION_TIME = 600
  BASIC_QUANTITY_OF_SHEETS = 25
  PLUS_QUANTITY_OF_SHEETS = 100
  PRO_QUANTITY_OF_SHEETS = 250
  BASIC_ROYALTY_PERCENTAGE = 0.80
  PLUS_ROYALTY_PERCENTAGE = 0.85
  PRO_ROYALTY_PERCENTAGE = 0.90
  AVATAR_MAX_WIDTH = 300
  AVATAR_MAX_HEIGHT = 300
  EXCEED_QUOTA_MESSAGE = "You have exceeded the number of sheets you can upload. Basic users get #{BASIC_QUANTITY_OF_SHEETS} uploads. Upgrade your membership to Plus or Pro to continue publishing on SheetHub."

  enum membership_type: %w{ basic plus pro staff }
  validates :username, presence: true, uniqueness: {case_sensitive: false}, if: :finished_registration?
  validates_acceptance_of :terms, acceptance: true
  validates_email_format_of :email, message: 'You have an invalid email address'
  validates_email_format_of :paypal_email, message: 'You have an invalid paypal account email address', if: :has_paypal_email?
  validate :validate_number_of_uploaded_sheets
  has_many :sheets, dependent: :destroy
  acts_as_voter

  has_attached_file :avatar,
                    :convert_options => {
                        :original => "-strip"},
                    :hash_secret => AVATAR_HASH_SECRET,
                    :default_url => MISSING_AVATAR_URL
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
  validates :avatar, :dimensions => { width: AVATAR_MAX_WIDTH, height: AVATAR_MAX_HEIGHT }
  attr_accessor :remove_avatar

  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :lockable
  devise :omniauthable, :omniauth_providers => [:facebook, :google_oauth2]

  def royalty_percentage
    return BASIC_ROYALTY_PERCENTAGE if basic?
    return PLUS_ROYALTY_PERCENTAGE if plus?
    return PRO_ROYALTY_PERCENTAGE if pro?
  end

  def joined_at
    created_at.strftime "%B %Y"
  end

  def display_name
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

  def public_sheets
    sheets.where(visibility: Sheet.visibilities[:vpublic])
  end

  def private_sheets
    sheets.where(visibility: Sheet.visibilities[:vprivate])
  end

  def has_paypal_email?
    paypal_email.present?
  end

  def sales
    Order.includes(:user).includes(:sheet).where(sheet_id: sheets.ids, status: Order.statuses[:completed])
  end

  def aggregated_sales
    result = {}
    sheets.each do |sheet|
      total_sales = sheet.total_sales
      result[sheet.title] = total_sales if total_sales > 0
    end
    return result
  end

  def aggregated_earnings
    sheets.inject(0) { |total, sheet| total + sheet.total_earnings }
  end

  def sales_past_month
    sales.where("purchased_at >= ?", 1.month.ago.utc)
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
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
      user.skip_confirmation!

      # Get normal quality picture if using omniauth-facebook
      if auth.provider == "facebook"
        user.image = auth.info.image + "?type=normal"
      else
        user.image = auth.info.image
      end
      user.save
    end
  end

  private
    def validate_number_of_uploaded_sheets
      errors.add(:sheets, EXCEED_QUOTA_MESSAGE) if sheets.size > sheet_quota
    end
end
