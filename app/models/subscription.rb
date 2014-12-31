# Encapculates premium memberships for Plus and Pro users
class Subscription < ActiveRecord::Base
  # Note: Basic users should not have a Subscription object associated

  SUBSCRIPTION_UNIQUENESS_VALIDATION_MESSAGE = 'Users cannot have multiple same-type subscriptions.'
  PLUS_BILLING_AGREEMENT_DESCRIPTION = 'Sheethub Plus Membership (US$12.00 per month)'
  PRO_BILLING_AGREEMENT_DESCRIPTION = 'Sheethub Pro Membership (US$24.00 per month)'
  PLUS_SUBSCRIPTION_AMOUNT = 12.00
  PRO_SUBSCRIPTION_AMOUNT = 24.00

  belongs_to :user
  enum status: %w(processing completed suspended)
  enum membership_type: %w( basic plus pro )
  validates :user_id,
            uniqueness: { scope: :membership_type,
                          message: SUBSCRIPTION_UNIQUENESS_VALIDATION_MESSAGE }
  before_destroy :cancel

  def self.subscription_amount(membership_type)
    return PLUS_SUBSCRIPTION_AMOUNT if membership_type == 'plus'
    return PRO_SUBSCRIPTION_AMOUNT if membership_type == 'pro'
  end

  def self.billing_agreement_description(membership_type)
    return PLUS_BILLING_AGREEMENT_DESCRIPTION if membership_type == 'plus'
    return PRO_BILLING_AGREEMENT_DESCRIPTION if membership_type == 'pro'
  end

  def complete(profile_id)
    if profile_id
      update(profile_id: profile_id, status: Subscription.statuses[:completed])
      user.update_membership_to(membership_type)
      SubscriptionMailer.purchase_success_email(self).deliver
    else
      raise 'Nil Profile Id on Subscription complete!'
    end
  end

  def cancel
    unless payment_details.status == 'Cancelled'
      Subscription.paypal_request.renew!(profile_id, :Cancel)
    end
    is_only_subscription = (user.completed_subscriptions.size == 1)
    user.update_membership_to('basic') if is_only_subscription
    SubscriptionMailer.cancellation_success_email(self).deliver
  end

  def payment_details
    Subscription.payment_details(profile_id)
  end

  def self.payment_details(profile_id)
    response = Subscription.paypal_request.subscription(profile_id)
    response.recurring
  end

  def self.paypal_request
    Paypal::Express::Request.new(
      username: Rails.application.secrets.paypal_username,
      password: Rails.application.secrets.paypal_password,
      signature: Rails.application.secrets.paypal_signature
    )
  end
end
