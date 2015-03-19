class AddPurchaseLimitsToSheets < ActiveRecord::Migration
  def change
    add_column :sheets, :limit_purchases, :boolean, default: false, null: false
    add_column :sheets, :limit_purchase_quantity, :integer, default: 0, null: false
  end
end
