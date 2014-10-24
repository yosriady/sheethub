class Order < ActiveRecord::Base
  validates :sheet_id, uniqueness: { scope: :user_id,
                       message: "Users cannot have multiple orders of the same Sheet." }
  validates :cart_id, absence: {if: "completed?", message: "Order cart_id must be cleared after purchase completion"}
  validates :cart_id, presence: {if: "processing?", message: "Order cart_id must exist while processing"}

  belongs_to :user
  belongs_to :sheet
  belongs_to :cart

  enum status: %w(processing completed failed)
end
