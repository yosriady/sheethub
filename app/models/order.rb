class Order < ActiveRecord::Base
  MISSING_PAYER_ID_MESSAGE = "Payer ID is nil!"

  validates :sheet_id, uniqueness: { scope: :user_id,
                       message: "Users cannot have multiple orders of the same Sheet." }
  validates :cart_id, absence: {if: "completed?", message: "Order cart_id must be cleared after purchase completion"}
  validates :cart_id, presence: {if: "processing?", message: "Order cart_id must exist while processing"}
  validates :payer_id, presence: {if: "completed?"}
  validates :payer_id, absence: {if: "processing?"}

  belongs_to :user
  belongs_to :sheet
  belongs_to :cart

  enum status: %w(processing completed failed)

  def complete(payer_id)
    raise MISSING_PAYER_ID_MESSAGE unless payer_id
    self.update(status: Order.statuses[:completed], payer_id: payer_id, purchased_at: Time.now)
    sheet.increment!(:total_sold)
  end
end
