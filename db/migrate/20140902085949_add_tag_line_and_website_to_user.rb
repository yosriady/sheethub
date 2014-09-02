class AddTagLineAndWebsiteToUser < ActiveRecord::Migration
  def change
    add_column :users, :tagline, :string
    add_column :users, :website, :string
  end
end
