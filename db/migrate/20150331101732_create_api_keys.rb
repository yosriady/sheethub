class CreateAPIKeys < ActiveRecord::Migration
  def change
    create_table :api_keys do |t|
      t.string :token, null: false
      t.integer :user_id, null: false

      t.timestamps null: false
    end
  end
end
