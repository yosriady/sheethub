class CreateSheets < ActiveRecord::Migration
  def change
    create_table :sheets do |t|
      t.boolean :is_public?, null: false, default: true
      t.boolean :is_flagged?, null: false, default: false
      t.boolean :is_free?, null: false, default: true
      t.boolean :is_original?, null: false, default: false
      t.decimal :price, precision: 2, null: false, default: 0
      t.string :title, null: false
      t.text :description, null: false
      t.integer :pages, null: false

      t.timestamps
    end
  end
end
