class AddPdfToOrders < ActiveRecord::Migration
  def change
    add_attachment :orders, :pdf
  end
end
