class RenameTokenToTrackingIdForOrders < ActiveRecord::Migration
  def change
    rename_column :orders, :token, :tracking_id
  end
end
