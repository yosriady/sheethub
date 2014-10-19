class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :sheet

  def purchase
    binding.pry
    response = PAYPAL_GATEWAY.purchase(order.total_amount_cents, paypal_purchase_options)
    response.success?
  end

  def paypal_token=(token)
    self[:paypal_token] = token
    if new_record? && !token.blank?
      # you can dump details var if you need more info from buyer
      details = PAYPAL_GATEWAY.details_for(token)
      self.paypal_payer_id = details.payer_id
    end
  end

  private

  def paypal_purchase_options
    {
      :ip => ip,
      :token => paypal_token,
      :payer_id => paypal_payer_id
    }
  end

end
