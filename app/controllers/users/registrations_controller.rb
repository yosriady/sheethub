class Users::RegistrationsController < Devise::RegistrationsController
  before_action :ensure_registration_finished

  # GET /user/:username
  def profile
    unless params[:username]
      # TODO: user not found page
    end

    @user = User.find_by("lower(username) = ?", params[:username].downcase)
    if @user
      @sheets = @user.sheets
    end
  end

  # GET /resource/edit
  def edit
    # TODO: Edit Profile
  end

  # User profile edit/update
  def update
    account_update_params = devise_parameter_sanitizer.sanitize(:account_update)

    # required for settings form to submit when password is left blank
    if account_update_params[:password].blank?
      account_update_params.delete("password")
      account_update_params.delete("password_confirmation")
    end

    @user = User.find(current_user.id)
    if @user.update_attributes(account_update_params)
      set_flash_message :notice, :updated
      sign_in @user, :bypass => true
      redirect_to profile_path(@user.username)
    else
      render "edit"
    end
  end

  # Finish registration fields edit/update
  def finish_registration
    if request.patch? && params[:user] && params[:user][:username]
      update_params = registration_params
      update_params[:finished_registration?] = true
      if current_user.update(update_params)
        redirect_to profile_path(current_user.username), notice: 'Your profile was successfully updated.'
      else
        flash[:error] = current_user.errors.full_messages.to_sentence
        redirect_to finish_registration_path, error: 'Your profile was not successfully updated.'
      end
    else
      # Render Form
    end
  end

  def destroy
    # Disable destroy
    p "Accounts cannot be deleted"
  end

  protected
    def registration_params
      params[:user].permit(:username, :finished_registration?, :tagline, :website)
    end

    def ensure_registration_finished
      if params[:action] == "finish_registration" && (!current_user || current_user.finished_registration?)
        redirect_to root_path
      end
    end
end