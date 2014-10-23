class CreateCarts < ActiveRecord::Migration
  def change
    create_table :carts do |t|
      t.string :paypal_token

      t.timestamps
    end
  end
end
