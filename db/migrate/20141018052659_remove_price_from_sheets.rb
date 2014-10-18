class RemovePriceFromSheets < ActiveRecord::Migration
  def change
    remove_column :sheets, :price, :decimal
  end
end
