# TODO: Refactor this to ENV
S3DirectUpload.config do |c|
  c.access_key_id = "AKIAI32VLLBYAJJ2THYA"       # your access key id
  c.secret_access_key = "STIW0JGoAnCR5R0CscwUzE/lf0ucxnK4AvKoOGU9"   # your secret access key
  c.bucket = "sheethub"              # your bucket name
  c.region = "ap-southeast-1"             # region prefix of your bucket url. This is _required_ for the non-default AWS region, eg. "s3-eu-west-1"
  c.url = "https://sheethub.s3.amazonaws.com/"                # S3 API endpoint (optional), eg. "https://#{c.bucket}.s3.amazonaws.com/"
end