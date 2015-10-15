# User model
class User < ActiveRecord::Base
  include Avatarable
  include Upgradable
  include Payable

  scope :is_active, -> { where(finished_registration?: true) }

  validates :username, presence: true, uniqueness: { case_sensitive: false }, format: { with: /\A[a-zA-Z0-9]+\Z/, message: "No spaces and no special characters allowed!"}, if: :finished_registration?
  validates_email_format_of :email, if: proc { |u| u.email_changed? }, message: 'You have an invalid email address'
  has_many :sheets, dependent: :destroy
  has_many :notes, dependent: :destroy
  acts_as_voter
  before_save :cache_display_name
  after_save :update_mixpanel_profile

  # Devise modules
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :validatable, :confirmable, :lockable
  devise :omniauthable, omniauth_providers: [:facebook, :google_oauth2]

  has_one :api_key
  has_many :orders

  def country
    return unless billing_country
    country = ISO3166::Country[billing_country]
    return if country.nil?
    country.translations.nil? ? country.name : country.translations[I18n.locale.to_s]
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

  def free_sheets
    sheets.where(price_cents: 0)
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
    return username unless first_name.present?
    if last_name.present?
      "#{first_name} #{last_name}"
    else
      first_name
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
