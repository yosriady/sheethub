class AddCachedDisplayNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :cached_display_name, :string
  end
end
