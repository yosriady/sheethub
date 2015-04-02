module PdfAttachable
  extend ActiveSupport::Concern

  included do
    EXPIRATION_TIME = 600
    PDF_PREVIEW_DEFAULT_URL = 'nil' # TODO: point to special Missing file route
    PDF_DEFAULT_URL = 'nil'
    MAX_FILESIZE = 20

    has_attached_file :pdf,
                      styles: {
                        preview: { geometry: '', format: :png }
                      },
                      processors: [:preview],
                      hash_secret: Rails.application.secrets.sheet_hash_secret,
                      default_url: PDF_DEFAULT_URL,
                      preserve_files: 'true',
                      s3_permissions: {
                        preview: :public_read,
                        original: :private
                      }
    validates_attachment_content_type :pdf,
                                      content_type: ['application/pdf']
    validates_attachment_size :pdf, in: 0.megabytes..MAX_FILESIZE.megabytes
    validates :pdf, presence: true
    before_save :extract_number_of_pages
  end

  def extract_number_of_pages
    return unless pdf?
    tempfile = pdf.queued_for_write[:original]
    unless tempfile.nil?
      pdf = MiniMagick::Image.open(tempfile.path)
      self.pages = pdf.pages.size
    end
  end

  def pdf_preview?
    pdf_preview_url.present? && pdf_preview_url != PDF_PREVIEW_DEFAULT_URL
  end

  def pdf_preview_url
    pdf.url(:preview) || PDF_PREVIEW_DEFAULT_URL
  end

  def pdf_download_url
    pdf.expiring_url(EXPIRATION_TIME)
  end
end
