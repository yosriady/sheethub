class AddSheetIdToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :sheet_id, :integer
  end
end
