class SubscriptionMailer < ActionMailer::Base
  DEFAULT_FROM_EMAIL = "notifications@sheethub.co"
  default from: DEFAULT_FROM_EMAIL

  def purchase_success_email(subscription)
    @subscription = subscription
    @membership_type = subscription.membership_type.titleize
    @buyer = subscription.user
    email_with_name = "#{@buyer.display_name} <#{@buyer.email}>"
    mail(to: email_with_name, subject: 'Welcome to SheetHub #{membership_type}!')
  end
end
