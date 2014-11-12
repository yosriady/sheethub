class AddRoyaltyAndCommissionToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :royalty_cents, :integer, null: false
  end
end
