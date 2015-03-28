class RemoveSheetQuotaFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :sheet_quota, default: 0, null: false
  end
end
