class UpdatePayerIdInOrders < ActiveRecord::Migration
  def change
    change_column :orders, :payer_id, :string, null: true
  end
end
