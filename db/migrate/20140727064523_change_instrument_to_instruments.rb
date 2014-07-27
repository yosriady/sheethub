class ChangeInstrumentToInstruments < ActiveRecord::Migration
  def change
    rename_column :sheets, :instrument, :instruments
  end
end
