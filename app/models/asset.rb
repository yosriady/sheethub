class Asset < ActiveRecord::Base
  EXPIRATION_TIME = 30
  MAX_FILESIZE = 20
  MAX_NUMBER_OF_ASSETS = 5
  ASSET_NUMBER_VALIDATION_MESSAGE = 'You can only have 5 additional files per sheet'
  INVALID_FILESIZE_MESSAGE = 'Files must be less than 20 Megabytes in size'

  belongs_to :sheet
  validate :validate_number_of_assets
  acts_as_paranoid
  validates_presence_of :sheet

  has_attached_file :file,
                    hash_secret: Rails.application.secrets.asset_hash_secret,
                    preserve_files: "true"
  validate :validate_file_size
  # TODO: validate attachment content type: MIDI, .ptb, .gp5, .tg, etc...

  def s3_key
    url.sub(S3DirectUpload.config.url, '')
  end

  def self.parse_s3_key(url)
    url.sub(S3DirectUpload.config.url, '')
  end

  def s3_object
    s3 = AWS::S3.new
    bucket = s3.buckets[S3DirectUpload.config.bucket]
    bucket.objects[s3_key]
  end

  def expiring_url(time = EXPIRATION_TIME)
    return unless if s3_object
    s3_object.url_for(:read, expires: time).to_s
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

  def validate_file_size
    valid_filesize = filesize.in?(0.megabytes..MAX_FILESIZE.megabytes)
    errors.add(:filesize, INVALID_FILESIZE_MESSAGE) unless valid_filesize
  end
end
