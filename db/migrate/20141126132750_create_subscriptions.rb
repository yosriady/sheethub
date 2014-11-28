class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :user_id, null: false
      t.integer :membership_type, null: false
      t.integer :status, default: 0
      t.string :tracking_id, null: false

      t.timestamps
    end
  end
end
