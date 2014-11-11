class AddNotNullConstraintToOrderColumns < ActiveRecord::Migration
  def change
    change_column :orders, :tracking_id, :string, :null => false
    change_column :orders, :payer_id, :string, :null => false
  end
end
