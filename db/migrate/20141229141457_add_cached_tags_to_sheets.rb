class AddCachedTagsToSheets < ActiveRecord::Migration
  def change
    add_column :sheets, :cached_genres, :string
    add_column :sheets, :cached_composers, :string
    add_column :sheets, :cached_sources, :string
  end
end
