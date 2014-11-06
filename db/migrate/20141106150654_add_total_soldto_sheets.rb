class AddTotalSoldtoSheets < ActiveRecord::Migration
  def change
    add_column :sheets, :total_sold, :integer, default: 0
  end
end
