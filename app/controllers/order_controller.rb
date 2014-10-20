class OrderController < ApplicationController
  def paypal_checkout
    sheet = Sheet.find(params[:sheet_id])
    request = Paypal::Express::Request.new(
      :username   => "yosriady-facilitator_api1.gmail.com",
      :password   => "H739SP4UDQSHEGAW",
      :signature  => "A6AFKLF9K9Odzd81iNIOAJrlric4AKKVz.DGUTuNFWqyRFUGYkyp5-Ya"
    )
    payment_request = Paypal::Payment::Request.new(
      :description   => "#{sheet.title} Sheet Music, from SheetHub",    # item description
      :quantity      => 1,      # item quantity
      :amount        => sheet.price   # item value
    )
    response = request.setup(
      payment_request,
      order_success_url,
      order_cancel_url,
      paypal_options  # Optional
    )
    redirect_to response.redirect_uri
  end

  def success
    binding.pry
    # TODO
    # get <code>token</code> and <code>PayerID</code> in query string.
    response = request.details(token)
    response.payer
    response.amount
    response.ship_to
    response.payment_responses
    response = request.checkout!(
      token,
      payer_id,
      payment_request
    )
    # Create Order object
    response.payment_info
  end

  def cancel
    binding.pry
  end

  def paypal_options
    return {
      no_shipping: true, # if you want to disable shipping information
      allow_note: false, # if you want to disable notes
      pay_on_paypal: true #if you want to commit the transaction in paypal instead of your site
    }
  end

end
