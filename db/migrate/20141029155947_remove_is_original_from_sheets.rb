class RemoveIsOriginalFromSheets < ActiveRecord::Migration
  def change
    remove_column :sheets, :is_original, :boolean
  end
end
