class Cart < ActiveRecord::Base
  validates :user_id, uniqueness: true #Users can only have one active cart
  belongs_to :user
  has_many :orders

  def add(sheet)
    orders.create(sheet_id: sheet.id, user_id: user_id)
  end

  def include?(sheet)
    sheets.ids.include?(sheet.id)
  end

  def remove(sheet)
    orders.where(sheet_id: sheet.id).destroy_all
  end

  def clear
    orders.destroy_all
  end

  def total
    sheets.sum(&:price)
  end

  private
    def sheets
      Sheet.find(orders.pluck(:sheet_id))
    end

end
