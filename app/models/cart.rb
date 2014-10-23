class Cart < ActiveRecord::Base
  validates :user_id, uniqueness: true #Users can only have one active cart
  belongs_to :user
  has_many :orders

  # TODO: validate against duplicates items in cart
  # Do this client side too

  def add

  end

  def include?(sheet)

  end

  def remove
    # TODO
  end

  def clear
  end

  def total

  end

end
