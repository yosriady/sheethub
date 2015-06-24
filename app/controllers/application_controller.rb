require 'mixpanel-ruby'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :ensure_registration_finishes
  after_filter :store_location
  before_filter :set_timezone
  before_filter :redirect_subdomain

  REQUEST_PATH_WHITELIST = ['/users/sign_in', '/users/sign_up',
    '/users/password/new', '/users/password/edit', '/users/confirmation',
    '/users/finish_registration', '/users/sign_out']

  def redirect_subdomain
    return unless request.subdomain == 'www'
    if Rails.env.development?
      port = ":#{request.port}"
      redirect_to [request.protocol, request.domain, port, request.fullpath].join
    else
      redirect_to [request.protocol, request.domain, request.fullpath].join
    end
  end

  def track(event_name, data = {})
    identifier = (user_signed_in? ? current_user.id : session.id)
    Analytics.track(identifier, event_name, data)
  end

  def set_timezone
    tz = current_user ? current_user.timezone : nil
    Time.zone = tz || ActiveSupport::TimeZone['UTC']
  end

  def store_location
    # store last url - this is needed for post-login redirect to whatever the user last visited.
    return unless request.get?
    unless request.path.in?(REQUEST_PATH_WHITELIST) || request.xhr? # don't store ajax calls
      session[:previous_url] = request.fullpath
    end
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || root_url
  end

  def ensure_registration_finishes
    return if action_name == 'finish_registration'
    return if !user_signed_in? || current_user.finished_registration?
    redirect_to finish_registration_url
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :username
  end
end
