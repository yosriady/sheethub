class OrdersController < ApplicationController
  MARKETPLACE_PAYPAL_EMAIL = "yosriady-facilitator@gmail.com"
  DEFAULT_CURRENCY = "USD"
  SUCCESS_ORDER_PURCHASE_MESSAGE = "Great success! Thank you for your purchase."
  CANCEL_ORDER_PURCHASE_MESSAGE = "Purchase canceled."

  before_action :authenticate_user!, :only => [:checkout, :success, :cancel]

  def checkout
    sheet = Sheet.friendly.find(params[:sheet])
    @order = Order.find_or_initialize_by(user_id: current_user.id, sheet_id: sheet.id)
    if @order.completed?
      redirect_to :back, error: "You've already purchased #{sheet.title}"
    end

    # Start Adaptive Payments
    api = PayPal::SDK::AdaptivePayments::API.new
    sheet = Sheet.friendly.find(params[:sheet])
    payment_request = build_adaptive_payment_request(sheet)
    @pay_response = api.pay(payment_request)
    if @pay_response.success?
      redirectURL = build_redirect_url(@pay_response.payKey)
      @order.tracking_id = payment_request.trackingId
      @order.payer_id = @pay_response.payKey
      @order.royalty_cents = sheet.royalty_cents
      @order.save
      redirect_to redirectURL
    else
      Rails.logger.info "Paypal Error #{@pay_response.error.first.errorId}: #{@pay_response.error.first.message}"
      if invalid_account_details_error(@pay_response)
        send_purchase_failure_email
        flash[:error] = "We could not process your purchase. The uploader's Paypal email is invalid!"
      else
        flash[:error] = "We could not process your purchase. #{@pay_response.error.first.message}"
      end
      redirect_to sheet_path(sheet)
    end
  end

  def success
    trackingId = params[:tracking_id]
    @order = Order.find_by(tracking_id: trackingId)
    if @order
      @order.complete
      render :action => "thank_you", notice: SUCCESS_ORDER_PURCHASE_MESSAGE
    else
      raise "Invalid Tracking Id"
    end
  end

  def thank_you
  end

  def cancel
    redirect_to sheets_path, notice: CANCEL_ORDER_PURCHASE_MESSAGE
  end

  private
    def generate_token
      token = loop do
        random_token = SecureRandom.urlsafe_base64(nil, false)
        break random_token unless Order.exists?(tracking_id: random_token)
      end
    end

    def build_adaptive_payment_request(sheet)
      trackingId = generate_token
      api = PayPal::SDK::AdaptivePayments::API.new
      pay_request = api.build_pay()
      pay_request.trackingId = trackingId
      pay_request.actionType = "PAY"

      pay_request.cancelUrl = orders_cancel_url
      pay_request.returnUrl = orders_success_url(trackingId)
      pay_request.currencyCode = DEFAULT_CURRENCY

      # Primary receiver (Sheet Owner)
      pay_request.receiverList.receiver[0].amount = sheet.price
      pay_request.receiverList.receiver[0].email  = sheet.user.paypal_email
      pay_request.receiverList.receiver[0].primary = true
      pay_request.receiverList.receiver[0].paymentType = "DIGITALGOODS"

      # Secondary Receiver (Marketplace)
      pay_request.receiverList.receiver[1].amount = sheet.commission
      pay_request.receiverList.receiver[1].email  = MARKETPLACE_PAYPAL_EMAIL
      pay_request.receiverList.receiver[1].primary = false
      pay_request.receiverList.receiver[1].paymentType = "DIGITALGOODS"
      return pay_request
    end

    def build_redirect_url(payKey)
      return "https://www.sandbox.paypal.com/webapps/adaptivepayment/flow/pay?paykey=#{payKey}"
    end

    def send_purchase_failure_email
      # TODO: Email user that purchase has failed because of invalid account details
    end

    def invalid_account_details_error?(pay_response)
      pay_response.error.first.errorId == 520009
    end
end