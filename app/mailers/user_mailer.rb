# Mailer class for emails related to user accounts and registration
class UserMailer < ApplicationMailer
  layout 'mailer'

  DEFAULT_FROM_EMAIL = 'SheetHub <notifications@sheethub.co>'
  default from: DEFAULT_FROM_EMAIL

  def welcome_email(user)
    @user = user
    email_with_name = "#{@user.display_name} <#{@user.email}>"
    mail(to: email_with_name, subject: 'Welcome to SheetHub')
  end
end
