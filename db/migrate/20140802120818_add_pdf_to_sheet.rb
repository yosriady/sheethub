class AddPdfToSheet < ActiveRecord::Migration
  def self.up
    add_attachment :sheets, :pdf
  end

  def self.down
    remove_attachment :sheets, :pdf
  end
end
