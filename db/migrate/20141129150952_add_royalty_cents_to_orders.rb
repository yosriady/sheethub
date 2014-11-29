class AddRoyaltyCentsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :royalty_cents, :integer
  end
end
