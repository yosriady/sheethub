# Encapsulates Orders, an association class between Sheets and Buyers.
class Order < ActiveRecord::Base
  EXPIRATION_TIME = 600
  ORDER_UNIQUENESS_VALIDATION_MESSAGE = 'Users cannot have multiple orders of the same Sheet.'
  WATERMARK_PATH = "#{Rails.root}/public/images/watermark.png"

  belongs_to :user, counter_cache: true
  belongs_to :sheet, counter_cache: true
  enum status: %w(processing completed failed)
  validates :sheet_id, uniqueness: { scope: :user_id,
                                   message: ORDER_UNIQUENESS_VALIDATION_MESSAGE }
  has_attached_file :pdf,
                    hash_secret: Rails.application.secrets.sheet_hash_secret,
                    default_url: Sheet::PDF_DEFAULT_URL
  validates_attachment_content_type :pdf, content_type: ['application/pdf']

  def complete
    return if completed?
    update(status: Order.statuses[:completed],
           purchased_at: Time.zone.now,
           billing_full_name: user.billing_full_name,
           billing_address_line_1: user.billing_address_line_1,
           billing_address_line_2: user.billing_address_line_2,
           billing_city: user.billing_city,
           billing_state_province: user.billing_state_province,
           billing_country: user.billing_country,
           billing_zipcode: user.billing_zipcode,
           ip: user.current_sign_in_ip)
    sheet.increment(:total_sold)
    sheet.decrement(:limit_purchase_quantity)
    sheet.save!
    send_completion_emails
    Analytics.track_charge(self)
  end

  def complete_free
    return if completed? || !sheet.free?
    tracking_id = Order.generate_token
    update(tracking_id: tracking_id,
          amount_cents: 0,
          price_cents: 0)
    complete
  end

  def send_completion_emails
    return if freely_completed?
    SheetMailer.sheet_out_of_stock_email(sheet).deliver if sheet.out_of_stock?
    OrderMailer.purchase_receipt_email(self).deliver
    OrderMailer.sheet_purchased_email(self).deliver
  end

  def self.generate_token
    token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless Order.exists?(tracking_id: random_token)
    end
  end

  def generate_watermarked_pdf
    pdf_path = sheet.pdf_download_url
    pdf = MiniMagick::Image.open(pdf_path)
    watermark = MiniMagick::Image.open(File.expand_path(WATERMARK_PATH))
    watermark.combine_options do |c|
      c.transparent 'white'
      c.alpha 'remove'
    end

    composited = pdf.pages.inject([]) do |composited, page|
      processed_page = page.composite(watermark) do |c|
        c.density '300'
        c.alpha 'remove'
        c.compose 'Over'
        c.geometry '+0+20'
        c.gravity 'NorthEast'
      end
      processed_page = processed_page.combine_options do |c|
        c.font 'Helvetica'
        c.gravity 'NorthWest'
        c.pointsize 32
        c.draw "text 50,20 'Licensed to #{user.display_name} <#{user.email}>'"
      end
      composited << processed_page
    end
    MiniMagick::Tool::Convert.new do |b|
      b.quality '92'
      b.resize '60%'
      composited.each { |page| b << page.path }
      b << pdf.path
    end

    pdf.write(sheet.pdf_file_name)
    watermarked = File.open(sheet.pdf_file_name)
    self.pdf = watermarked
    self.save!
    File.delete(watermarked) # Delete temp file
  end

  def latest_pdf?
    return false unless pdf.updated_at
    sheet.pdf.updated_at < pdf.updated_at
  end

  def pdf_download_url
    return false unless completed?
    return sheet.pdf.expiring_url unless sheet.enable_pdf_stamping
    generate_watermarked_pdf unless latest_pdf?
    pdf.expiring_url(EXPIRATION_TIME)
  end

  # TODO: Refactor out to a common CSV interface
  def csv_data
    [updated_at.to_s, sheet.title,
      ActionController::Base.helpers.number_to_currency(price),
      ActionController::Base.helpers.number_to_currency(amount),
      ActionController::Base.helpers.number_to_currency(royalty), user.email,
     ip, billing_full_name, billing_address_line_1,
     billing_address_line_2, billing_city,
     billing_state_province, billing_country, billing_zipcode]
  end

  def amount
    amount_cents.to_f / 100
  end

  def royalty
    royalty_cents.to_f / 100
  end

  def price
    price_cents.to_f / 100
  end

  def commission
    (amount - royalty).round(2)
  end

  def self.calculate_commission(author, amount)
    ((1 - author.royalty_percentage) * amount).round(2)
  end

  def self.calculate_royalty_cents(author, amount_cents)
    author.royalty_percentage * amount_cents
  end

  def self.get_payment_details(order)
    api = PayPal::SDK::AdaptivePayments::API.new
    payment_details_request = api.build_payment_details
    payment_details_request.payKey = order.payer_id
    payment_details_response = api.payment_details(payment_details_request)
    if payment_details_response.success?
      return payment_details_response
    else
      fail "Payment Details for payKey #{payKey} Not Found"
    end
  end

  def payment_completed?
    Order.get_payment_details(self).paymentInfoList.paymentInfo[0].transactionStatus == 'COMPLETED'
  end

  def freely_completed?
    amount_cents.zero?
  end

  def s3_key
    pdf.url.sub(S3DirectUpload.config.url, '')
  end

  def delete_s3_object(key)
    s3 = AWS::S3.new
    file = s3.buckets['sheethub'].objects[key]
    file.delete
  end
end
