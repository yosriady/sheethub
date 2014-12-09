class Subscription < ActiveRecord::Base
  SUBSCRIPTION_UNIQUENESS_VALIDATION_MESSAGE = "Users cannot have multiple same-type subscriptions."
  PLUS_BILLING_AGREEMENT_DESCRIPTION = "Sheethub Plus Membership (US$8.00 per month)"
  PRO_BILLING_AGREEMENT_DESCRIPTION = "Sheethub Pro Membership (US$24.00 per month)"
  PLUS_SUBSCRIPTION_AMOUNT = 8.00
  PRO_SUBSCRIPTION_AMOUNT = 24.00

  belongs_to :user
  enum status: %w(processing completed suspended)
  enum membership_type: %w{ basic plus pro }
  validates :user_id, uniqueness: { scope: :membership_type, message: SUBSCRIPTION_UNIQUENESS_VALIDATION_MESSAGE }
  # Basic users should not have a Subscription object associated
  before_destroy :cancel

  def self.subscription_amount(membership_type)
    return PLUS_SUBSCRIPTION_AMOUNT if membership_type == "plus"
    return PRO_SUBSCRIPTION_AMOUNT if membership_type == "pro"
  end

  def self.billing_agreement_description(membership_type)
    return PLUS_BILLING_AGREEMENT_DESCRIPTION if membership_type == "plus"
    return PRO_BILLING_AGREEMENT_DESCRIPTION if membership_type == "pro"
  end

  def complete(profile_id)
    if profile_id
      update(profile_id: profile_id, status: Subscription.statuses[:completed])
      user.update_membership_to(membership_type)
      SubscriptionMailer.purchase_success_email(self).deliver
    else
      raise "Nil Profile Id on Subscription complete!"
    end
  end

  def cancel
    unless get_payment_details.status == "Cancelled"
      Subscription.paypal_request.renew!(profile_id, :Cancel)
    end
    user.update_membership_to("basic") if user.completed_subscriptions.empty?
  end

  def get_payment_details
    Subscription.get_payment_details(profile_id)
  end

  def self.get_payment_details(profile_id)
    response = Subscription.paypal_request.subscription(profile_id)
    response.recurring
  end

  def self.paypal_request
    Paypal::Express::Request.new(
      :username   => Rails.application.secrets.paypal_username,
      :password   => Rails.application.secrets.paypal_password,
      :signature  => Rails.application.secrets.paypal_signature
    )
  end


end
