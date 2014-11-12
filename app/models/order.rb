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
      send_sold_email_to_owner(self)
    end
  end

  def send_sold_email_to_owner
    # TODO
    binding.pry
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
