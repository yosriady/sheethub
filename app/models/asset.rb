class Asset < ActiveRecord::Base
  ASSET_HASH_SECRET = "sheethubhashsecret"
  EXPIRATION_TIME = 600
  MAX_FILESIZE = 20
  MAX_NUMBER_OF_ASSETS = 5
  ASSET_NUMBER_VALIDATION_MESSAGE = "You can only have 5 additional files per sheet"

  belongs_to :sheet
  validate :validate_number_of_assets
  acts_as_paranoid
  validates_presence_of :sheet

  has_attached_file :file,
                    :hash_secret => ASSET_HASH_SECRET, #TODO: Use ENV for this
                    :preserve_files => "true"
  # validates_attachment_size :file, :in => 0.megabytes..MAX_FILESIZE.megabytes
  # TODO: validate attachment content type: MIDI, .ptb, .gp5, .tg, etc...

  def s3_key
    url.sub(S3DirectUpload.config.url, '')
  end

  def s3_object
    s3 = AWS::S3.new
    bucket = s3.buckets[S3DirectUpload.config.bucket]
    s3_object = bucket.objects[s3_key]
  end

  def expiring_url(time = EXPIRATION_TIME, style_name = :original)
    if s3_object
      s3_object.url_for(:read, :expires => time).to_s
    end
  end

  def download_url
    expiring_url
  end

  private
    def validate_number_of_assets
      sheet = Sheet.find(sheet_id)
      valid_number_of_assets = sheet.assets.count < MAX_NUMBER_OF_ASSETS
      errors.add(:sheet_id, ASSET_NUMBER_VALIDATION_MESSAGE) unless valid_number_of_assets
    end

end
