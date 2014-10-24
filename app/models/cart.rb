class Cart < ActiveRecord::Base
  validates :user_id, uniqueness: true # Users can only have one active cart
  validates :cart_id, absence: true, if: "completed?"
  validates :cart_id, presence: true, if: "processing?"
  belongs_to :user
  has_many :orders

  def add(sheet)
    if !sheet.purchased_by?(User.find(user_id)) && !include?(sheet)
      orders.create(sheet_id: sheet.id, user_id: user_id)
    end
  end

  def include?(sheet)
    sheets.map(&:id).include?(sheet.id)
  end

  def remove(sheet)
    orders.where(sheet_id: sheet.id).destroy_all
  end

  def complete_orders
    orders.map{|o| o.update(status: Order.statuses[:completed], purchased_at: Time.now)}
  end

  def clear_token
    paypal_token = nil
  end

  def clear_orders
    orders.each{|o| o.update(cart_id: nil)}
  end

  def total
    sheets.sum(&:price)
  end

  def sheets
    Sheet.find(orders.pluck(:sheet_id))
  end

end
