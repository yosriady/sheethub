class AddOrdersCountToSheets < ActiveRecord::Migration
  def change
    add_column :sheets, :orders_count, :integer, default: 0, null:false
    change_column :sheets, :assets_count, :integer, default: 0, null:false
    change_column :users, :orders_count, :integer, default: 0, null:false
    change_column :users, :sheets_count, :integer, default: 0, null:false
  end
end
