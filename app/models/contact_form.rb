class ContactForm < MailForm::Base
  attribute :name,      validate: true
  attribute :from,     validate: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :to,     validate: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i

  attribute :subject,   validate: true
  attribute :message,   validate: true

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    {
      subject: "New Message: #{subject}",
      to: to,
      from: %("#{name}" <#{from}>)
    }
  end
end