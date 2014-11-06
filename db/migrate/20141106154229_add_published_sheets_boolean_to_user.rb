class AddPublishedSheetsBooleanToUser < ActiveRecord::Migration
  def change
    add_column :users, :has_published, :boolean, default: false
  end
end
