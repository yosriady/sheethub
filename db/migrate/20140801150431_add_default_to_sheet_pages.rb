class AddDefaultToSheetPages < ActiveRecord::Migration
  def change
    change_column :sheets, :pages, :integer, default: 0
  end
end
