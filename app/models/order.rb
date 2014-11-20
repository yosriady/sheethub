# Encapsulates Orders, an association class between Sheets and Buyers.
class Order < ActiveRecord::Base
  ORDER_UNIQUENESS_VALIDATION_MESSAGE = "Users cannot have multiple orders of the same Sheet."

  validates :sheet_id, uniqueness: { scope: :user_id,
                       message: ORDER_UNIQUENESS_VALIDATION_MESSAGE }

  has_attached_file :pdf
  belongs_to :user
  belongs_to :sheet

  enum status: %w(processing completed failed)

  def complete
    unless completed?
      update(status: Order.statuses[:completed], purchased_at: Time.now)
      sheet.increment!(:total_sold)

      # Start generating watermarked pdf

      OrderMailer.purchase_receipt_email(self).deliver
      OrderMailer.sheet_purchased_email(self).deliver
    end
  end

  def amount
    amount_cents.to_f / 100
  end

  def royalty
    (Sheet::USER_ROYALTY_PERCENTAGE * amount - paypal_transaction_fees).round(2)
  end

  def paypal_transaction_fees
    (0.029 * amount) + 0.3
  end

  def self.get_adaptive_payment_details(payKey)
    api = PayPal::SDK::AdaptivePayments::API.new
    payment_details_request = api.build_payment_details
    payment_details_request.payKey = payKey
    payment_details_response = api.payment_details(payment_details_request)
    if payment_details_response.success?
      return payment_details_response
    else
      fail "Payment Details for payKey #{payKey} Not Found"
    end
  end

end
