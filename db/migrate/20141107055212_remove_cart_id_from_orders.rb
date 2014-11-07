class RemoveCartIdFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :cart_id, :integer
  end
end
