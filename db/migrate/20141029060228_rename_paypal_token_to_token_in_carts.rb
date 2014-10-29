class RenamePaypalTokenToTokenInCarts < ActiveRecord::Migration
  def change
    rename_column :carts, :paypal_token, :token
  end
end
