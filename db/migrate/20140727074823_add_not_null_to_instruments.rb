class AddNotNullToInstruments < ActiveRecord::Migration
  def change
    change_column :sheets, :instruments, :integer, :null => false
  end
end
