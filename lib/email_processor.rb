class EmailProcessor
  def initialize(email)
    @email = email
  end

  def process
    # Forward emails to yosriady@gmail.com, then reply as alias support@sheethub.co
    SupportMailer.forward_support_email(@email)
  end
end