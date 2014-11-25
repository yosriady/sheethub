class UpgradesController < ApplicationController
  before_action :authenticate_user!

  def purchase
    membership_type = upgrades_params[:membership]
    # render upgrade checkout page
  end

  def checkout
    # Redirect to Paypal
  end

  def success
    token, payer_id = parseTokenAndPayerIdFromQueryString(request)



  end

  def cancel
    redirect_to upgrade_path, notice: CANCEL_UPGRADE_PURCHASE_MESSAGE
  end

  def thank_you
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

    def build_payment_request(membership_type)
      # Paypal::Payment::Request.new(
      #   :description   => sheet.title,    # item description
      #   :quantity      => 1,      # item quantity
      #   :billing_type  => :RecurringPayments,
      #   :amount        => sheet.price
      # )
    end

    def paypal_request
      Paypal::Express::Request.new(
        :username   => PAYPAL_USERNAME,
        :password   => PAYPAL_PASSWORD,
        :signature  => PAYPAL_SIGNATURE
      )
    end

    def upgrades_params
      params.permit(:membership)
    end
end
