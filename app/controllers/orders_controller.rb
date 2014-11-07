class OrdersController < ApplicationController
  SUCCESS_ORDER_PURCHASE_MESSAGE = "Purchase successful."
  CANCEL_ORDER_PURCHASE_MESSAGE = "Purchase canceled."

  before_action :authenticate_user!, :only => [:checkout, :success, :cancel]

 def checkout
    sheet = Sheet.friendly.find(params[:sheet])
    payment_request = build_payment_request(sheet)
    response = paypal_request.setup(
      payment_request,
      orders_success_url,
      orders_cancel_url,
      paypal_options
    )
    @order = Order.find_or_initialize_by(user_id: current_user.id, sheet_id: sheet.id)
    @order.token = response.token

    if @order.save
      redirect_to response.redirect_uri
    else
      redirect_to :back, error: @order.errors.full_messages.to_sentence
    end
  end

  def success
    token, payer_id = parseTokenAndPayerIdFromQueryString(request)
    @order = Order.where(token: token).first
    payment_request = build_payment_request(@order.sheet)
    response = paypal_request.details(token)
    response = paypal_request.checkout!(
      token,
      payer_id,
      payment_request
    )

    @order.complete(payer_id)
    render :action => "thank_you", notice: SUCCESS_ORDER_PURCHASE_MESSAGE
  end

  def thank_you
  end

  def cancel
    redirect_to sheets_path, notice: CANCEL_ORDER_PURCHASE_MESSAGE
  end

  private
    def parseTokenAndPayerIdFromQueryString(request)
      return request.query_parameters["token"], request.query_parameters["PayerID"]
    end

    def paypal_options
      return {
        no_shipping: true,
        allow_note: false, # if you want to disable notes
        pay_on_paypal: true #if you want to commit the transaction in paypal instead of your site
      }
    end

    def build_payment_request(sheet)
      Paypal::Payment::Request.new(
        :description   => sheet.title,    # item description
        :quantity      => 1,      # item quantity
        :amount        => sheet.price
      )
    end

    def paypal_request
      Paypal::Express::Request.new(
        :username   => PAYPAL_USERNAME,
        :password   => PAYPAL_PASSWORD,
        :signature  => PAYPAL_SIGNATURE
      )
    end
end