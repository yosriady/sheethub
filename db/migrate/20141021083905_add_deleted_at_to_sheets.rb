class AddDeletedAtToSheets < ActiveRecord::Migration
  def change
    add_column :sheets, :deleted_at, :datetime
    add_index :sheets, :deleted_at
  end
end
