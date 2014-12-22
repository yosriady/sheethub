class SupportMailer < ApplicationMailer

  def forward_support_email(email)
    @email = email
    mail(from: email.from, to: "yosriady@gmail.com", subject: email.subject)
  end


end
