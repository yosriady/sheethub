class RemoveNotNullFromInstruments < ActiveRecord::Migration
  def change
    change_column :sheets, :instruments, :integer, :null => true
  end
end
