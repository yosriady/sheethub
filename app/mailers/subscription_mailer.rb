class SubscriptionMailer < ActionMailer::Base
  include Roadie::Rails::Automatic
  layout 'mailer'

  DEFAULT_FROM_EMAIL = "SheetHub <notifications@sheethub.co>"
  default from: DEFAULT_FROM_EMAIL

  def purchase_success_email(subscription)
    @subscription = subscription
    @membership_type = subscription.membership_type.titleize
    @buyer = subscription.user
    email_with_name = "#{@buyer.display_name} <#{@buyer.email}>"
    email_subject = "Welcome to SheetHub #{@membership_type}!"
    mail(to: email_with_name, subject: email_subject)
  end

  def cancellation_success_email(subscription)
    @subscription = subscription
    @membership_type = subscription.membership_type.titleize
    @buyer = subscription.user
    email_with_name = "#{@buyer.display_name} <#{@buyer.email}>"
    email_subject = "#{@membership_type}! Membership Cancelled"
    mail(to: email_with_name, subject: email_subject)
  end
end
