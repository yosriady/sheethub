class AddPublishingRightToSheets < ActiveRecord::Migration
  def change
    add_column :sheets, :publishing_right, :integer, null: false
  end
end
