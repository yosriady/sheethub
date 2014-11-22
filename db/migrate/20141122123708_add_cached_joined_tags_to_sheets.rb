class AddCachedJoinedTagsToSheets < ActiveRecord::Migration
  def change
    add_column :sheets, :cached_joined_tags, :string
  end
end
