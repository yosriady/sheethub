class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.integer :user_id, null: false
      t.string :title, limit: 255, null: false
      t.string :slug, limit: 255
      t.text :body, null: false
      t.integer :visibility, default: 0
      t.integer :type, default: 0

      t.timestamps null: false
    end
  end
end
