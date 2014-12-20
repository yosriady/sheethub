AWS.config({
  access_key_id: Rails.application.secrets.s3_access_key_id,
  secret_access_key: Rails.application.secrets.s3_secret_access_key,
  region: Rails.application.secrets.s3_region
})