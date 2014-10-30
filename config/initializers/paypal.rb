PAYPAL_MODE = "sandbox"
PAYPAL_CLASSIC_APP_ID = "APP-80W284485P519543T" #SANDBOX
PAYPAL_USERNAME = "yosriady-facilitator_api1.gmail.com"
PAYPAL_PASSWORD = "H739SP4UDQSHEGAW"
PAYPAL_SIGNATURE = "A6AFKLF9K9Odzd81iNIOAJrlric4AKKVz.DGUTuNFWqyRFUGYkyp5-Ya"

PayPal::SDK.logger = Rails.logger
PayPal::SDK.configure(
  :mode      => PAYPAL_MODE,  # Set "live" for production
  :app_id    => PAYPAL_CLASSIC_APP_ID,
  :username  => PAYPAL_USERNAME,
  :password  => PAYPAL_PASSWORD,
  :signature => PAYPAL_SIGNATURE)