class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :sheet_id
      t.integer :user_id
      t.string :ip
      t.string :description
      t.string :paypal_token
      t.string :paypal_payer_id
      t.datetime :purchased_at

      t.timestamps
    end
  end
end
