class AddMemberShipTypeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :membership_type, :integer, null: false, default: 0
  end
end
