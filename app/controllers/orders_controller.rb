class OrdersController < ApplicationController
  SUCCESS_ORDER_MESSAGE = "Thank you for your purchase! You can view your purchases from your profile."
  ALREADY_COMPLETED_ORDER_MESSAGE = "Order already complete. You can view your purchases from your profile."
  FAILURE_ORDER_MESSAGE = "Order Failed."
  CANCEL_ORDER_MESSAGE = "Order Canceled."

  before_action :authenticate_user!, :only => [:paypal_checkout, :success, :cancel]
  # TODO: prevent buying own stuff?
  # before_action :verify_non_ownership, :only => [:paypal_checkout]

  def paypal_checkout
    sheet = Sheet.find(params[:sheet_id])
    payment_request = build_payment_request(sheet)
    response = paypal_request.setup(
      payment_request,
      orders_success_url,
      orders_cancel_url,
      paypal_options
    )
    Order.create(sheet_id: sheet.id, user_id: current_user.id, status: 'processing', paypal_token: response.token, ip: request.ip)
    redirect_to response.redirect_uri
  end

  def success
    token, payer_id = parseTokenAndPayerIdFromQueryString(request)
    @order = Order.where(paypal_token: token).first
    if @order.completed?
      redirect_to sheets_path, notice: ALREADY_COMPLETED_ORDER_MESSAGE
    end

    @sheet = Sheet.find(@order.sheet_id)
    payment_request = build_payment_request(@sheet)
    response = paypal_request.details(token)
    response = paypal_request.checkout!(
      token,
      payer_id,
      payment_request
    )

    # TODO: multiple item statuses for Cart
    payment_info = response.payment_info
    if response.payment_info[0].payment_status == "Completed"
      @order.update(status: 'completed', purchased_at: Time.now)
      render :action => "thank_you", notice: SUCCESS_ORDER_MESSAGE
    else
      @order.update(status: 'failed')
      redirect_to sheet_path(@sheet), notice: FAILURE_ORDER_MESSAGE
    end
  end

  def thank_you
  end

  def cancel
    token = request.query_parameters["token"]
    @order = Order.where(paypal_token: token).first
    @order.update(status: 'canceled')
    redirect_to sheets_path, notice: CANCEL_ORDER_MESSAGE
  end

  private
    def parseTokenAndPayerIdFromQueryString(request)
      return request.query_parameters["token"], request.query_parameters["PayerID"]
    end

    def paypal_options
      return {
        no_shipping: true, # if you want to disable shipping information
        allow_note: false, # if you want to disable notes
        pay_on_paypal: true #if you want to commit the transaction in paypal instead of your site
      }
    end

    def build_payment_request(sheet)
      Paypal::Payment::Request.new(
        :description   => "#{sheet.title} Sheet Music",    # item description
        :quantity      => 1,      # item quantity
        :amount        => sheet.price   # item value
      )
    end

    def paypal_request
      Paypal::Express::Request.new(
        :username   => "yosriady-facilitator_api1.gmail.com",
        :password   => "H739SP4UDQSHEGAW",
        :signature  => "A6AFKLF9K9Odzd81iNIOAJrlric4AKKVz.DGUTuNFWqyRFUGYkyp5-Ya"
      )
    end
end
