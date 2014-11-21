class AddSheetQuotaToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sheet_quota, :integer, null:false, default: 0
  end
end
