class SheetMailer < ActionMailer::Base
  DEFAULT_FROM_EMAIL = "SheetHub <notifications@sheethub.co>"
  default from: DEFAULT_FROM_EMAIL

  def sheet_favorited_email(sheet, user)
    @user = user
    @sheet = sheet
    @publisher = sheet.user
    email_with_name = "#{@publisher.display_name} <#{@publisher.email}>"
    mail(to: email_with_name, subject: 'Sheet Favorited')
  end

end
