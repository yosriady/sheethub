class MonetizeSheet < ActiveRecord::Migration
  def change
    add_column :sheets, :price_cents, :integer
  end
end
