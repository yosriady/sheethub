class AddPriceCentsToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :price_cents, :integer, null: false
  end
end
