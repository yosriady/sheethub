class AddUserIndexToNotes < ActiveRecord::Migration
  def change
    add_index "notes", ["user_id"], name: "index_notes_on_user_id", using: :btree
  end
end
