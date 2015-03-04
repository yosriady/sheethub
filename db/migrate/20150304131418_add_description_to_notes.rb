class AddDescriptionToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :description, :text, null: false
  end
end
