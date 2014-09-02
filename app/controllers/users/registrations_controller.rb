class Users::RegistrationsController < Devise::RegistrationsController
  before_action :ensure_registration_finished

  # GET /user/:username
  def profile
    @user = User.find_by("lower(username) = ?", params[:username].downcase)
    if @user
      @sheets = @user.sheets
    end
  end

  # GET /resource/edit
  def edit
    # Disallow users from editing their account details i.e. email, username
    redirect_to profile_path(current_user.username)
  end

  def finish_registration
    if request.patch? && params[:user] && params[:user][:username]
      update_params = registration_params
      update_params[:finished_registration?] = true
      if current_user.update(update_params)
        redirect_to root_path, notice: 'Your profile was successfully updated.'
      else
        flash[:error] = current_user.errors.full_messages.to_sentence
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
      if params[:action] == "finish_registration" && (!current_user || current_user.finished_registration?)
        redirect_to root_path
      end
    end
end