class User < ActiveRecord::Base
  AVATAR_HASH_SECRET = "sheethubhashsecret"
  MISSING_AVATAR_URL = "/images/missing.png"

  has_many :sheets, dependent: :destroy
  acts_as_voter

  has_attached_file :avatar,
                    :styles => { :thumb => "100x100>" },
                    :hash_secret => AVATAR_HASH_SECRET,
                    :default_url => MISSING_AVATAR_URL
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
  attr_accessor :remove_avatar

  validates :username, presence: true, uniqueness: {case_sensitive: false}, if: :finished_registration?

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, :omniauth_providers => [:facebook, :google_oauth2]

  def joined_at
    created_at.strftime "%B %Y"
  end

  def avatar_url
    if avatar.url.present? && avatar.url != MISSING_AVATAR_URL
      avatar.url(:thumb)
    else
      image
    end
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name

      # Get normal quality picture if using omniauth-facebook
      if auth.provider == "facebook"
        user.image = auth.info.image + "?type=normal"
      else
        user.image = auth.info.image
      end

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
