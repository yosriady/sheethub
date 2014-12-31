class AddBillingAddressToUser < ActiveRecord::Migration
  def change
    add_column :users, :billing_full_name, :string
    add_column :users, :billing_street_line_1, :string
    add_column :users, :billing_street_line_2, :string
    add_column :users, :billing_city, :string
    add_column :users, :billing_state_province, :string
    add_column :users, :billing_country, :string
    add_column :users, :billing_zipcode, :string
  end
end
