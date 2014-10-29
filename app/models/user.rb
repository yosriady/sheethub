class User < ActiveRecord::Base
  AVATAR_HASH_SECRET = "sheethubhashsecret"
  MISSING_AVATAR_URL = "/images/missing.png"
  EXPIRATION_TIME = 600

  validates :username, presence: true, uniqueness: {case_sensitive: false}, if: :finished_registration?
  validates_acceptance_of :terms, acceptance: true
  has_many :sheets, dependent: :destroy
  has_one :cart
  acts_as_voter

  has_attached_file :avatar,
                    :convert_options => {
                        :original => "-strip"},
                    :hash_secret => AVATAR_HASH_SECRET,
                    :default_url => MISSING_AVATAR_URL
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
  attr_accessor :remove_avatar

  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
  devise :omniauthable, :omniauth_providers => [:facebook, :google_oauth2]

  def public_sheets
    sheets.where(is_public: true)
  end

  def private_sheets
    sheets.where(is_public: false)
  end

  def purchased_sheets
    Sheet.find(purchased_sheet_ids)
  end

  def sales_past_month
    Order.where(sheet_id: sheets.ids).where("purchased_at >= ?", 1.month.ago.utc)
  end

  def purchased_sheet_ids
    completed_orders.collect{|o| o.sheet_id}
  end

  def completed_orders
    Order.where(user_id: id, status: Order.statuses[:completed])
  end

  def deleted_sheets
    Sheet.only_deleted.where(user_id: id)
  end

  def joined_at
    created_at.strftime "%B %Y"
  end

  def full_name
    (first_name.present? || last_name.present?) ? "#{first_name} #{last_name}" : name
  end

  def avatar_url
    if avatar.url.present? && avatar.url != MISSING_AVATAR_URL
      avatar.expiring_url(EXPIRATION_TIME, :original)
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

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

end
