module Avatarable
  extend ActiveSupport::Concern

  included do
    AVATAR_HASH_SECRET = 'sheethubhashsecret'
    MISSING_AVATAR_URL = 'default_avatar.png'
    AVATAR_MAX_WIDTH = 300
    AVATAR_MAX_HEIGHT = 300

    has_attached_file :avatar,
                      convert_options: {
                        original: '-strip'
                      },
                      hash_secret: AVATAR_HASH_SECRET,
                      default_url: MISSING_AVATAR_URL,
                      s3_permissions: :public_read
    validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/
    validates :avatar, dimensions: { width: AVATAR_MAX_WIDTH,
                                     height: AVATAR_MAX_HEIGHT }
    attr_accessor :remove_avatar

    scope :with_avatars, -> { User.where.not(image: nil).where.not(username: nil) }
  end

  def avatar_url
    if avatar.url.present? && avatar.url != MISSING_AVATAR_URL
      avatar.url
    elsif image.present?
      image
    else
      MISSING_AVATAR_URL
    end
  end
end
