class Users::RegistrationsController < Devise::RegistrationsController
  SUCCESS_UPDATE_PROFILE_MESSAGE = 'Your profile was successfully updated.'
  FAILURE_UPDATE_PROFILE_MESSAGE = 'Your profile was not successfully updated.'

  before_action :ensure_registration_finished
  before_action :authenticate_user!, :only => [:purchases, :sales, :trash]

  # GET /user/:username
  def profile
    unless params[:username]
      # TODO: user not found page
    end

    # TODO: refactor by using includes for better performance
    @user = User.includes(:sheets).find_by("lower(username) = ?", params[:username].downcase)
    if @user
      @sheets = @user.public_sheets
      @likes = @user.find_voted_items
      @private_sheets = @user.private_sheets if current_user == @user
    end
  end

  def purchases
    @purchases = current_user.purchased_sheets
  end

  def sales
    # TODO
  end

  def trash
     @deleted_sheets = current_user.deleted_sheets
  end

  # GET /resource/edit
  def edit
  end

  # User profile edit/update
  def update
    account_update_params = registration_params

    # required for settings form to submit when password is left blank
    if account_update_params[:password].blank?
      account_update_params.delete("password")
      account_update_params.delete("password_confirmation")
    end

    @user = User.find(current_user.id)
    if @user.update_attributes(account_update_params)
      set_flash_message :notice, :updated
      sign_in @user, :bypass => true
      redirect_to user_profile_path(@user.username)
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
        redirect_to user_profile_path(current_user.username), notice: SUCCESS_UPDATE_PROFILE_MESSAGE
      else
        flash[:error] = current_user.errors.full_messages.to_sentence
        redirect_to finish_registration_path, error: FAILURE_UPDATE_PROFILE_MESSAGE
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
      params[:user].permit(:username, :finished_registration?, :tagline, :website, :bio, :avatar)
    end

    def ensure_registration_finished
      if params[:action] == "finish_registration" && (!current_user || current_user.finished_registration?)
        redirect_to root_path
      end
    end
end