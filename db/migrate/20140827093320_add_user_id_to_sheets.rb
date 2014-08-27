class AddUserIdToSheets < ActiveRecord::Migration
  def change
    add_column :sheets, :user_id, :integer, null: false
  end
end
