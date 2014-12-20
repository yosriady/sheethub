PayPal::SDK.logger = Rails.logger
PayPal::SDK.configure(
  mode: Rails.application.secrets.paypal_mode,
  app_id: Rails.application.secrets.paypal_classic_app_id,
  username: Rails.application.secrets.paypal_username,
  password: Rails.application.secrets.paypal_password,
  signature: Rails.application.secrets.paypal_signature
)
