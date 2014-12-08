class SubscriptionsController < ApplicationController
  SUCCESS_SUBSCRIPTION_PURCHASE_MESSAGE = ""
  DOWNGRADE_TO_BASIC_SUBSCRIPTION_MESSAGE = "You've Downgraded to a Basic membership. We're sorry to see you go."
  CANCEL_UPGRADE_PURCHASE_MESSAGE = "Upgrade purchase canceled."
  ERROR_UPGRADE_PURCHASE_MESSAGE = "Upgrade purchase error. Please contact support."

  before_action :authenticate_user!
  before_action :validate_membership, only: [:purchase, :checkout, :suspend, :reactivate]
  before_action :validate_existing_membership, only: [:purchase, :checkout, :downgrade]

  def purchase
  end

  def checkout
    payment_response = build_payment_response(subscriptions_params[:membership])

    if payment_response.ack == "Success"
      # Finds previous in-progress subscription if exists
      @subscription = Subscription.find_or_initialize_by(membership_type: Subscription.membership_types[subscriptions_params[:membership]], user_id:current_user.id, status: Subscription.statuses[:processing])
      @subscription.update(tracking_id: payment_response.token)
      redirect_to payment_response.redirect_uri
    else
      Rails.logger.info "Paypal Subscription Error #{payment_response.error.first.errorId}: #{payment_response.error.first.message}"
      redirect_to upgrade_path, notice: ERROR_UPGRADE_PURCHASE_MESSAGE
    end
  end

  def success
    @subscription = finalize_new_subscription(request)

    # Cancels previous subscription if exists
    user_subscriptions = @subscription.user.completed_subscriptions
    has_previous_subscription = (user_subscriptions.size > 1)
    if has_previous_subscription
      user_subscriptions.first.destroy
    end

    render action: 'thank_you', notice: SUCCESS_SUBSCRIPTION_PURCHASE_MESSAGE
  end

  def cancel
    redirect_to upgrade_path, notice: CANCEL_UPGRADE_PURCHASE_MESSAGE
  end

  def downgrade
    if current_user.hit_free_sheet_quota_for_basic?
      flash[:error] = "You need to delete some of your free sheets before you can downgrade. You have #{current_user.free_sheets.size} of an allowed #{User::BASIC_FREE_SHEET_QUOTA} free sheets."
      redirect_to user_membership_settings_path
    else
      membership = subscriptions_params[:membership]
      current_user.subscription.destroy
      current_user.update_membership_to(membership)
      redirect_to user_membership_settings_path, notice: DOWNGRADE_TO_BASIC_SUBSCRIPTION_MESSAGE
    end
  end

  def thank_you
  end

  private
    def finalize_new_subscription(request)
      token = parseTokenFromQueryString(request)
      subscription = Subscription.find_by(tracking_id: token)
      payment_request = build_payment_request(subscription.membership_type)
      profile = Paypal::Payment::Recurring.new(
        :start_date => Time.zone.now,
        :description => Subscription.billing_agreement_description(subscription.membership_type),
        :auto_bill => 'AddToNextBilling',
        :billing => {
          :period        => :Month,
          :frequency     => 1,
          :amount        => Subscription.subscription_amount(subscription.membership_type)
        }
      )
      response = Subscription.paypal_request.subscribe!(token, profile)
      subscription.complete(response.recurring.identifier)
      return subscription
    end

    def parseTokenFromQueryString(request)
      request.query_parameters["token"]
    end

    def paypal_options
      return {
        no_shipping: true,
        allow_note: false,
        pay_on_paypal: true
      }
    end

    def build_payment_request(membership_type)
      Paypal::Payment::Request.new(
        :billing_type  => :RecurringPayments,
        :billing_agreement_description => Subscription.billing_agreement_description(membership_type)
      )
    end

    def build_payment_response(membership_type)
      payment_request = build_payment_request(subscriptions_params[:membership])
      payment_response = Subscription.paypal_request.setup(
                          payment_request,
                          subscriptions_success_url,
                          subscriptions_cancel_url
                        )
    end

    def validate_membership
      unless subscriptions_params[:membership].in? ['plus', 'pro']
        flash[:error] = "Membership type does not exist"
        redirect_to upgrade_path
      end
    end

    def validate_existing_membership
      if current_user.membership_type == subscriptions_params[:membership]
        flash[:error] = "You are already a #{current_user.membership_type.titleize} member."
        redirect_to upgrade_path
      end
    end

    def subscriptions_params
      params.permit(:membership, :_method, :authenticity_token)
    end
end
