class AddDefaultStatusToOrders < ActiveRecord::Migration
  def change
    change_column :orders, :status, :integer, default: 0
    remove_column :orders, :ip, :string
    remove_column :orders, :description, :string
  end
end
