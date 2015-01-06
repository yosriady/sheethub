class AddBillingDataAndIpToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :billing_full_name, :string
    add_column :orders, :billing_address_line_1, :string
    add_column :orders, :billing_address_line_2, :string
    add_column :orders, :billing_city, :string
    add_column :orders, :billing_state_province, :string
    add_column :orders, :billing_country, :string
    add_column :orders, :billing_zipcode, :string
    add_column :orders, :ip, :inet
  end
end
