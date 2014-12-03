S3DirectUpload.config do |c|
  c.access_key_id = Rails.application.secrets.s3_access_key_id
  c.secret_access_key = Rails.application.secrets.s3_secret_access_key
  c.bucket = Rails.application.secrets.s3_bucket
  c.region = Rails.application.secrets.s3_region
  c.url = Rails.application.secrets.s3_bucket_url
end