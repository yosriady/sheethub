class AddFkIndexes < ActiveRecord::Migration
  def change
    add_index :assets, :sheet_id
    add_index :orders, :sheet_id
    add_index :flags, :sheet_id
    add_index :sheets, :user_id
    add_index :orders, :user_id
    add_index :flags, :user_id
  end
end
