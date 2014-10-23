class CartsController < ApplicationController
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

  def paypal_checkout
    payment_request = build_payment_request(@cart)
    response = paypal_request.setup(
      payment_request,
      carts_success_url,
      carts_cancel_url,
      paypal_options
    )
    @cart.paypal_token = response.token
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
    binding.pry
    @cart.complete_orders
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
        no_shipping: true, # if you want to disable shipping information
        allow_note: false, # if you want to disable notes
        pay_on_paypal: true #if you want to commit the transaction in paypal instead of your site
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
        :username   => "yosriady-facilitator_api1.gmail.com",
        :password   => "H739SP4UDQSHEGAW",
        :signature  => "A6AFKLF9K9Odzd81iNIOAJrlric4AKKVz.DGUTuNFWqyRFUGYkyp5-Ya"
      )
    end
end
