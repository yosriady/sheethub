# Controller for Orders
class OrdersController < ApplicationController
  MARKETPLACE_PAYPAL_EMAIL = 'yosriady-facilitator@gmail.com'
  DEFAULT_CURRENCY = 'USD'
  SUCCESS_ORDER_PURCHASE_MESSAGE = 'Great success! Thank you for your purchase.'
  CANCEL_ORDER_PURCHASE_MESSAGE = 'Purchase canceled.'

  before_action :authenticate_user!, only: [:checkout, :success, :cancel]
  before_action :validate_flagged, only: [:checkout]

  def checkout
    sheet = Sheet.friendly.find(params[:sheet])
    @order = Order.find_or_initialize_by(user_id: current_user.id,
                                         sheet_id: sheet.id)
    if @order.completed?
      redirect_to :back, error: "You've already purchased #{sheet.title}"
    end

    # Start Adaptive Payments
    api = PayPal::SDK::AdaptivePayments::API.new
    sheet = Sheet.friendly.find(params[:sheet])
    payment_request = build_adaptive_payment_request(sheet)
    @pay_response = api.pay(payment_request)
    if @pay_response.success?
      redirect_url = build_redirect_url(@pay_response.payKey)
      @order.tracking_id = payment_request.trackingId
      @order.payer_id = @pay_response.payKey
      @order.amount_cents = sheet.price_cents #TODO: For pay what you want, update this OK?
      @order.save
      redirect_to redirect_url
    else
      Rails.logger.info "Paypal Error #{@pay_response.error.first.errorId}: #{@pay_response.error.first.message}"
      if invalid_account_details_error?(@pay_response)
        OrderMailer.purchase_failure_email(@order).deliver
        flash[:error] = "We could not process your purchase. The publisher's Paypal email is invalid! We've sent out an email."
      else
        flash[:error] = "We could not process your purchase. #{@pay_response.error.first.message}"
      end
      redirect_to sheet_path(sheet)
    end
  end

  def success
    tracking_id = params[:tracking_id]
    @order = Order.find_by(tracking_id: tracking_id)
    if @order
      @order.complete
      render action: 'thank_you', notice: SUCCESS_ORDER_PURCHASE_MESSAGE
    else
      fail 'Invalid Tracking Id'
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
      tracking_id = generate_token
      api = PayPal::SDK::AdaptivePayments::API.new
      pay_request = api.build_pay
      pay_request.trackingId = tracking_id
      pay_request.actionType = 'PAY'

      pay_request.cancelUrl = orders_cancel_url
      pay_request.returnUrl = orders_success_url(tracking_id)
      pay_request.currencyCode = DEFAULT_CURRENCY

      # Primary receiver (Sheet Owner)
      pay_request.receiverList.receiver[0].amount = sheet.price
      pay_request.receiverList.receiver[0].email  = sheet.user.paypal_email
      pay_request.receiverList.receiver[0].primary = true

      # Secondary Receiver (Marketplace)
      pay_request.receiverList.receiver[1].amount = sheet.commission
      pay_request.receiverList.receiver[1].email  = MARKETPLACE_PAYPAL_EMAIL
      pay_request.receiverList.receiver[1].primary = false
      return pay_request
    end

    def build_redirect_url(payKey)
      return "https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_ap-payment&paykey=#{payKey}"
    end

    def invalid_account_details_error?(pay_response)
      pay_response.error.first.errorId == 520009
    end

    def validate_flagged
      sheet = Sheet.friendly.find(params[:sheet])
      if sheet.is_flagged
        flash[:error] = FLAGGED_MESSAGE
        redirect_to sheets_path
      end
    end
end
