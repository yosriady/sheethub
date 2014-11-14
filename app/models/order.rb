class Order < ActiveRecord::Base
  validates :sheet_id, uniqueness: { scope: :user_id,
                       message: "Users cannot have multiple orders of the same Sheet." }

  belongs_to :user
  belongs_to :sheet

  enum status: %w(processing completed failed)

  def complete
    if !completed?
      self.update(status: Order.statuses[:completed], purchased_at: Time.now)
      sheet.increment!(:total_sold)
      OrderMailer.purchase_receipt_email(self).deliver
      OrderMailer.sheet_purchased_email(self).deliver
    end
  end

  def amount
    return amount_cents.to_f / 100
  end

  def royalty
    return ((Sheet::USER_ROYALTY_PERCENTAGE * amount) - paypal_transaction_fees).round(2)
  end

  def paypal_transaction_fees
    return (0.029 * amount) + 0.3
  end

  def self.get_adaptive_payment_details(payKey)
    api = PayPal::SDK::AdaptivePayments::API.new
    payment_details_request = api.build_payment_details()
    payment_details_request.payKey = payKey
    payment_details_response = api.payment_details(payment_details_request)
    if payment_details_response.success?
      return payment_details_response
    else
      raise "Payment Details for payKey #{payKey} Not Found"
    end
  end

end
