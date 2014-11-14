class ReplaceRoyaltyCentsWithAmountCentsInOrder < ActiveRecord::Migration
  def change
    rename_column :orders, :royalty_cents, :amount_cents
  end
end
