class CartsController < ApplicationController
  SUCCESS_CART_PURCHASE_MESSAGE = "Purchase successful."
  SUCCESS_CART_ADD_MESSAGE = "Item added to cart."
  SUCCESS_CART_REMOVE_MESSAGE = "Item removed from cart."
  CANCEL_CART_PURCHASE_MESSAGE = "Purchase canceled."

  before_action :authenticate_user!, :only => [:paypal_checkout, :success, :cancel]

  def add
    sheet = Sheet.find(params[:sheet_id])
    @cart.add(sheet)
    redirect_to :back, notice: SUCCESS_CART_ADD_MESSAGE
  end

  def remove
    sheet = Sheet.find(params[:sheet_id])
    @cart.remove(sheet)
    redirect_to :back, notice: SUCCESS_CART_REMOVE_MESSAGE
  end

  def checkout
  end

  def paypal_checkout
    payment_request = build_payment_request(@cart)
    response = paypal_request.setup(
      payment_request,
      carts_success_url,
      carts_cancel_url,
      paypal_options
    )
    @cart.token = response.token
    # redirect_to response.popup_uri
    redirect_to response.redirect_uri
  end

  def success
    token, payer_id = parseTokenAndPayerIdFromQueryString(request)
    payment_request = build_payment_request(@cart)
    response = paypal_request.details(token)
    response = paypal_request.checkout!(
      token,
      payer_id,
      payment_request
    )

    @cart.complete_orders(payer_id)
    @purchased_sheets = @cart.sheets
    @cart.clear_token
    @cart.clear_orders
    render :action => "thank_you", notice: SUCCESS_CART_PURCHASE_MESSAGE
  end

  def thank_you
  end

  def cancel
    redirect_to sheets_path, notice: CANCEL_CART_PURCHASE_MESSAGE
  end

  private
    def parseTokenAndPayerIdFromQueryString(request)
      return request.query_parameters["token"], request.query_parameters["PayerID"]
    end

    def paypal_options
      return {
        no_shipping: true
      }
    end

    def build_payment_request(cart)
      Paypal::Payment::Request.new(
        :description   => "Sheet Music from SheetHub",    # item description
        :quantity      => cart.orders.size,      # item quantity
        :amount        => cart.total,   # item value
        :items         => build_payment_items(cart.orders)
      )
    end

    def build_payment_items(orders)
      orders.map{|o| {
        :name => o.sheet.title,
        :amount => o.sheet.price,
        :category => :Digital,
        :url => sheet_url(o.sheet)
      }}
    end

    def paypal_request
      Paypal::Express::Request.new(
        :username   => PAYPAL_USERNAME,
        :password   => PAYPAL_PASSWORD,
        :signature  => PAYPAL_SIGNATURE
      )
    end
end
