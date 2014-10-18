class MonetizeSheet < ActiveRecord::Migration
  def change
    add_column :sheets, :price_cents, :integer, null: false, default: 0
  end
end
