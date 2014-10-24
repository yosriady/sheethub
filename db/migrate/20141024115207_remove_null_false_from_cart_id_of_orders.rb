class RemoveNullFalseFromCartIdOfOrders < ActiveRecord::Migration
  def change
    change_column :orders, :cart_id, :integer, null: true
  end
end
