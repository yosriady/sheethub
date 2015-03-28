class MakeLicenseOptional < ActiveRecord::Migration
  def change
    change_column :sheets, :license, :integer, null: true
  end
end
