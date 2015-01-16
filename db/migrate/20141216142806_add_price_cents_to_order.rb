class AddPriceCentsToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :price_cents, :integer, default: 0
  end
end
