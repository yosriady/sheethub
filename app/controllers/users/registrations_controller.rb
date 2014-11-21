class Users::RegistrationsController < Devise::RegistrationsController
  SUCCESS_UPDATE_PROFILE_MESSAGE = "Nice! You've successfully updated your profile."
  FAILURE_UPDATE_PROFILE_MESSAGE = 'Your profile was not successfully updated.'

  before_action :set_user, :only => [:profile, :favorites, :sheets]
  before_action :validate_registration_finished
  before_action :validate_has_published, :only => [:sales]
  before_action :authenticate_user!, :only => [:purchases, :sales, :trash, :private_music]

  # GET /user/:username
  def profile
    unless params[:username]
      raise ActionController::RoutingError.new('User Not Found')
    end

    @sheets = @user.public_sheets.page(params[:page]) if @user
  end

  def private_sheets
    @private_sheets = current_user.private_sheets.page(params[:page])
  end

  def favorites
    @favorites = @user.votes.includes(:votable).page(params[:page])
  end

  def purchases
    @purchases = current_user.purchased_orders.page(params[:page])
  end

  def sales
    @aggregated_sales = current_user.aggregated_sales
    @sales_past_month = current_user.sales_past_month
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
      flash[:error] = @user.errors.full_messages.to_sentence
      render "edit"
    end
  end

  # Finish registration fields edit/update
  def finish_registration
    if request.patch? && params[:user] && params[:user][:username]
      update_params = registration_params
      update_params[:finished_registration?] = true
      update_params[:sheet_quota] = User::FREE_QUANTITY_OF_SHEETS
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
    def set_user
      @user = User.find_by("username = ?", params[:username])
    end

    def registration_params
      params[:user].permit(:username, :finished_registration?, :tagline, :website, :avatar, :terms, :paypal_email, :first_name, :last_name, :sheet_quota)
    end

    def validate_registration_finished
      if params[:action] == "finish_registration" && (!current_user || current_user.finished_registration?)
        redirect_to root_path
      end
    end

    def validate_has_published
      redirect_to root_path, notice: "Sales is only available when you have a published sheet." unless current_user.has_published
    end
end