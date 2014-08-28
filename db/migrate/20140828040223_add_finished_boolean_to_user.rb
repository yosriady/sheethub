class AddFinishedBooleanToUser < ActiveRecord::Migration
  def change
    add_column :users, :finished_registration?, :boolean, default: false
  end
end
