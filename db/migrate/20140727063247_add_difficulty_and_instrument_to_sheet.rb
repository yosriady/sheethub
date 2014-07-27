class AddDifficultyAndInstrumentToSheet < ActiveRecord::Migration
  def change
    add_column :sheets, :difficulty, :integer
    add_column :sheets, :instrument, :integer
  end
end
