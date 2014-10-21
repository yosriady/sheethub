class AddDeletedAtToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :deleted_at, :datetime
    add_index :assets, :deleted_at
  end
end
