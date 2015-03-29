class AddCategoryToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :category, :integer, default: 0, null: false
  end
end
