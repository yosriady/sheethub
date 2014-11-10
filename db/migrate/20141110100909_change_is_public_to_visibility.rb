class ChangeIsPublicToVisibility < ActiveRecord::Migration
  def change
    remove_column :sheets, :is_public, :boolean
    add_column :sheets, :visibility, :integer, default: 0
  end
end
