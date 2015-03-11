class AddSoundCloudAndYoutubeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :soundcloud_username, :string
    add_column :users, :youtube_username, :string
  end
end
