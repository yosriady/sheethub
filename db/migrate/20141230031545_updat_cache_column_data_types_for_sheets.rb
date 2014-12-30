class UpdatCacheColumnDataTypesForSheets < ActiveRecord::Migration
  def change
    remove_column :sheets, :cached_joined_tags, :string
    remove_column :sheets, :cached_genres, :string
    remove_column :sheets, :cached_composers, :string
    remove_column :sheets, :cached_sources, :string
    add_column :sheets, :cached_joined_tags, :string, array: true, default: []
    add_column :sheets, :cached_genres, :string, array: true, default: []
    add_column :sheets, :cached_composers, :string, array: true, default: []
    add_column :sheets, :cached_sources, :string, array: true, default: []
  end
end
