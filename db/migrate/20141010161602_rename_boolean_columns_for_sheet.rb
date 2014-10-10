class RenameBooleanColumnsForSheet < ActiveRecord::Migration
  def change
    rename_column :sheets, :is_public?, :is_public
    rename_column :sheets, :is_flagged?, :is_flagged
    rename_column :sheets, :is_free?, :is_free
    rename_column :sheets, :is_original?, :is_original
  end
end
