# Mailer class for emails related to the Sheet model
class SheetMailer < ActionMailer::Base
  layout 'mailer'

  DEFAULT_FROM_EMAIL = 'SheetHub <notifications@sheethub.co>'
  default from: DEFAULT_FROM_EMAIL

  def sheet_out_of_stock_email(sheet)
    @sheet = sheet
    @publisher = sheet.user
    email_with_name = "#{@publisher.display_name} <#{@publisher.email}>"
    mail(to: email_with_name, subject: 'Sheet Out of Stock')
  end

  def sheet_liked_email(sheet, user)
    @user = user
    @sheet = sheet
    @publisher = sheet.user
    email_with_name = "#{@publisher.display_name} <#{@publisher.email}>"
    mail(to: email_with_name, subject: 'You Have a New Fan!')
  end

  def sheet_flagged_email(flag)
    @flag = flag
    @sheet = flag.sheet
    mail(to: 'yosriady@gmail.com', subject: 'A Sheet is Flagged')
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
