class CartsController < ApplicationController
  before_action :authenticate_user!, :only => [:paypal_checkout, :success, :cancel]

  def add
    sheet = Sheet.find(params[:sheet_id])
    binding.pry
    @cart
    redirect_to :back
  end

  def paypal_checkout
    binding.pry
  end

  def success
    binding.pry
  end

  def thank_you
    binding.pry
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

    def build_payment_request
      # TODO: build payment request based on items in @cart
      binding.pry
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
