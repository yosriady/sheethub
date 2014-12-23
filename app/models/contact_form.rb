class ContactForm < MailForm::Base
  append :remote_ip, :user_agent

  attribute :name,      validate: true
  attribute :email,     validate: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i

  attribute :subject,   validate: true
  attribute :message,   validate: true

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    {
      subject: "SheetHub Support: #{subject}",
      to: "yosriady@gmail.com",
      from: %("#{name}" <#{email}>)
    }
  end
end