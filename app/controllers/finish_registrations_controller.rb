class FinishRegistrationsController < ApplicationController
  before_action :ensure_registration_finished

  def finish_registration
    if request.patch? && params[:user] && params[:user][:username]
      update_params = registration_params
      update_params[:finished_registration?] = true
      if current_user.update(update_params)
        redirect_to root_path, notice: 'Your profile was successfully updated.'
      else
        redirect_to finish_registration_path, error: 'Your profile was not successfully updated.'
      end
    else
      # Render Form
    end
  end

  protected
    def registration_params
      params[:user].permit(:username, :finished_registration?)
    end

    def ensure_registration_finished
      if !current_user || current_user.finished_registration?
        redirect_to root_path
      end
    end


end
