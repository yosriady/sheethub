# Overriden Devise Sessions Control for Discourse Forum's SSO (Single Sign On)
class Users::SessionsController < Devise::SessionsController
  before_action :validate_user_signed_in, only: [:sso]

  def sso
    secret = Rails.application.secrets.discourse_sso_secret
    sso = SingleSignOn.parse(request.query_string, secret)
    sso.email = current_user.email
    sso.name = current_user.display_name
    sso.username = current_user.username
    sso.external_id = current_user.id # unique to your application
    sso.sso_secret = secret
    redirect_to sso.to_url('http://forum.sheethub.co/session/sso_login')
  end

  protected

  def validate_user_signed_in
    redirect_to new_user_session_url unless user_signed_in?
  end
end