# Encapsulates Orders, an association class between Sheets and Buyers.
class Order < ActiveRecord::Base
  EXPIRATION_TIME = 600
  ORDER_UNIQUENESS_VALIDATION_MESSAGE = 'Users cannot have multiple orders of the same Sheet.'
  WATERMARK_PATH = "#{Rails.root}/public/images/watermark.png"

  belongs_to :user
  belongs_to :sheet
  enum status: %w(processing completed failed)
  validates :sheet_id, uniqueness: { scope: :user_id,
                                   message: ORDER_UNIQUENESS_VALIDATION_MESSAGE }
  has_attached_file :pdf,
                    hash_secret: Rails.application.secrets.sheet_hash_secret,
                    default_url: Sheet::PDF_DEFAULT_URL
  validates_attachment_content_type :pdf, content_type: ['application/pdf']

  def complete
    return if completed?
    update(status: Order.statuses[:completed], purchased_at: Time.zone.now)
    sheet.increment!(:total_sold)
    OrderMailer.purchase_receipt_email(self).deliver_later
    OrderMailer.sheet_purchased_email(self).deliver_later
    Analytics.track_charge(self)
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

  def self.get_adaptive_payment_details(payKey)
    api = PayPal::SDK::AdaptivePayments::API.new
    payment_details_request = api.build_payment_details
    payment_details_request.payKey = payKey
    payment_details_response = api.payment_details(payment_details_request)
    if payment_details_response.success?
      return payment_details_response
    else
      fail "Payment Details for payKey #{payKey} Not Found"
    end
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
