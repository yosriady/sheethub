class AddCacheCounters < ActiveRecord::Migration
  def change
    add_column :sheets, :assets_count, :integer, default: 0
    add_column :users, :orders_count, :integer, default: 0
    add_column :users, :sheets_count, :integer, default: 0
  end
end
