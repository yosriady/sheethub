class RemoveIsFreeFromSheets < ActiveRecord::Migration
  def change
    remove_column :sheets, :is_free, :boolean
  end
end
