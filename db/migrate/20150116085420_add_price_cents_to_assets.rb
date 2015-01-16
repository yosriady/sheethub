class AddPriceCentsToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :price_cents, :integer
  end
end
