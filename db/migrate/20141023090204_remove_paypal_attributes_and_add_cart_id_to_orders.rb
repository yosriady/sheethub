class RemovePaypalAttributesAndAddCartIdToOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :paypal_token, :string
    remove_column :orders, :paypal_payer_id, :string
    change_column :orders, :sheet_id, :integer, null: false
    change_column :orders, :user_id, :integer, null: false
    add_column :orders, :cart_id, :integer, null: false
  end
end
