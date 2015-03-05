class AddSocialUserNamesToUser < ActiveRecord::Migration
  def change
    add_column :users, :facebook_username, :string
    add_column :users, :twitter_username, :string
    add_column :users, :googleplus_username, :string
  end
end
