class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.integer :user_id, null: false
      t.string :title, limit: 255, null: false
      t.string :slug, limit: 255
      t.text :body, null: false
      t.integer :body_type, default: 0
      t.integer :visibility, default: 0

      t.timestamps null: false
    end
    add_index "notes", ["slug"], name: "index_notes_on_slug", unique: true, using: :btree
  end
end
