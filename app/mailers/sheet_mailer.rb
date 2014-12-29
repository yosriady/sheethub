# Mailer class for emails related to the Sheet model
class SheetMailer < ActionMailer::Base
  include Roadie::Rails::Automatic
  layout 'mailer'

  DEFAULT_FROM_EMAIL = 'SheetHub <notifications@sheethub.co>'
  default from: DEFAULT_FROM_EMAIL

  def sheet_favorited_email(sheet, user)
    @user = user
    @sheet = sheet
    @publisher = sheet.user
    email_with_name = "#{@publisher.display_name} <#{@publisher.email}>"
    mail(to: email_with_name, subject: 'You have a new fan!')
  end

  def sheet_flagged_email(flag)
    @flag = flag
    @sheet = flag.sheet
    mail(to: 'yosriady@gmail.com', subject: 'A Sheet has been flagged')
  end

  def sheet_deleted_email(sheet)
    @sheet = sheet
    @publisher = sheet.user
    email_with_name = "#{@publisher.display_name} <#{@publisher.email}>"
    mail(to: email_with_name, subject: 'Sheet Soft-Deleted')
  end

  def sheet_really_deleted_email(sheet)
    @sheet = sheet
    @publisher = sheet.user
    email_with_name = "#{@publisher.display_name} <#{@publisher.email}>"
    mail(to: email_with_name, subject: 'Sheet Permanently Deleted')
  end
end
