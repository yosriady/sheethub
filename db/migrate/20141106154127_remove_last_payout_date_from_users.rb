class RemoveLastPayoutDateFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :last_payout_date, :datetime
  end
end
