class AddCachedPublishersToSheets < ActiveRecord::Migration
  def change
    add_column :sheets, :cached_publishers, :string
  end
end
