class Cart < ActiveRecord::Base
  validates :user_id, uniqueness: true #Users can only have one active cart
  belongs_to :user
  has_many :orders

end
