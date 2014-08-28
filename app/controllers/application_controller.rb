class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :ensure_registration_finishes

  def ensure_registration_finishes
    return if action_name == 'finish_registration'

    if current_user && !current_user.finished_registration?
      redirect_to finish_registration_path
    end
  end


  protected
    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) << :username
    end
end
