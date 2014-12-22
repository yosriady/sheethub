class OrderMailer < ActionMailer::Base
  include Roadie::Rails::Automatic

  DEFAULT_FROM_EMAIL = "SheetHub <notifications@sheethub.co>"
  default from: DEFAULT_FROM_EMAIL

  def purchase_failure_email(order)
    @sheet = order.sheet
    @publisher = @sheet.user
    email_with_name = "#{@publisher.display_name} <#{@publisher.email}>"
    mail(to: email_with_name, subject: 'Purchase Failure Notification')
  end

  # For Buyer
  def purchase_receipt_email(order)
    @sheet = order.sheet
    @buyer = order.user
    @order = order
    email_with_name = "#{@buyer.display_name} <#{@buyer.email}>"
    mail(to: email_with_name, subject: 'Thank You for Your Purchase')
  end

  # For Seller/Publisher
  def sheet_purchased_email(order)
    @sheet = order.sheet
    @order = order
    @buyer = order.user
    @publisher = @sheet.user
    email_with_name = "#{@publisher.display_name} <#{@publisher.email}>"
    mail(to: email_with_name, subject: "You've made a sale")
  end
end
