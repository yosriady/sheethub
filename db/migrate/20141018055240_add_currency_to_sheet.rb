class AddCurrencyToSheet < ActiveRecord::Migration
  def change
    add_column :sheets, :currency, :string
  end
end
