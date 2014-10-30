class AddLastPayoutDateToUser < ActiveRecord::Migration
  def change
    add_column :users, :last_payout_date, :datetime, null:false, default: Time.now
  end
end
