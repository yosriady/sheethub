# Be sure to restart your server when you modify this file.

if Rails.env.production?
  Rails.application.config.session_store :cookie_store, key: '_sheethub_session', domain: ".sheethub.co"
else
  Rails.application.config.session_store :cookie_store, key: '_sheethub_session', domain: "lvh.me"
end
