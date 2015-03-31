class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :membership_type, :first_name, :last_name, :tagline, :website, :facebook_username, :twitter_username, :googleplus_username,
    :soundcloud_username, :timezone, :avatar, :has_published, :sheets_count

  has_many :sheets

  def avatar
    {
      url: object.avatar_url,
      filetype: object.avatar_content_type,
      filesize: object.avatar_file_size,
      updated_at: object.avatar_updated_at
    }
  end
end
