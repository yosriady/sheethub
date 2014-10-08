class CreateFlags < ActiveRecord::Migration
  def change
    create_table :flags do |t|
      t.integer :user_id
      t.integer :sheet_id, null: false
      t.string :email
      t.text :message, null: false

      t.timestamps
    end
  end
end
