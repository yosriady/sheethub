class RenameBillingStreetToAddressForUsers < ActiveRecord::Migration
  def change
    rename_column :users, :billing_street_line_1, :billing_address_line_1
    rename_column :users, :billing_street_line_2, :billing_address_line_2
  end
end
