class RenamePublishingRightWithLicense < ActiveRecord::Migration
  def change
    rename_column :sheets, :publishing_right, :license
  end
end
