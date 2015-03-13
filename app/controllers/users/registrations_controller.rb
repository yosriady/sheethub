# Additional User management logic on top of Devise
class Users::RegistrationsController < Devise::RegistrationsController
  SUCCESS_UPDATE_PROFILE_MESSAGE = "Nice! You've successfully updated your profile."
  FAILURE_UPDATE_PROFILE_MESSAGE = 'Your profile was not successfully updated.'
  ONLY_PRO_MESSAGE = 'That feature is only available to Pro Users. Upgrade to Pro today!'
  PUBLISHER_ONLY_FEATURE_MESSAGE = 'This feature is only available when you have a published sheet.'

  before_action :validate_user_signed_in, except: [:new, :create, :profile, :likes]
  before_action :disable_for_omniauth, only: [:edit_password]
  before_action :set_profile_user, only: [:profile, :likes]
  before_action :validate_registration_finished
  before_action :validate_has_published, only: [:sales, :dashboard]
  before_action :set_current_user, only: [:edit_password, :edit_membership]

  # GET /user/:username
  def profile
    unless @user
      raise ActionController::RoutingError.new('User Not Found')
    end

    track('View profile', { user_id: @user.id, username: @user.username })
    @sheets = @user.public_sheets.page(params[:page]) if @user
  end

  def all
    @users = User.is_active.page(params[:page])
  end

  def dashboard
    track('View dashboard')
    @sheets = current_user.sheets.page(params[:page])
  end

  def likes
    track('View likes')
    @likes = @user.votes.includes(:votable).page(params[:page])
  end

  def library
    track('View library')
    @purchases = current_user.purchased_orders.includes(sheet: [:assets]).page(params[:page])
  end

  def sales
    track('View sales')
    @all_sales = current_user.sales.page(params[:page])
    @all_time_sales = current_user.all_time_sales
    @sales_past_month = current_user.sales_past_month
    @sales_past_month_by_country = current_user.sales_past_month_by_country
  end

  def csv_sales_data
    @sales_data = current_user.csv_sales_data
    respond_to do |format|
      format.csv { send_data @sales_data, filename: "sales-#{Time.zone.now.strftime('%b %d %Y').parameterize}.csv" }
    end
  end

  def trash
    track('View trash')
    @deleted_sheets = current_user.deleted_sheets
  end

  # GET /resource/edit
  def edit
    track('View settings')
  end

  def edit_membership
    track('View membership settings')
    subscription = current_user.premium_subscription
    @payment_details = subscription.payment_details if subscription.present?
  end

  def edit_password
  end

  def update_password
    @user = User.find(current_user.id)
    if @user.update_with_password(password_params)
      sign_in @user, bypass: true
      flash[:notice] = 'Password changed successfully'
      redirect_to user_password_settings_url
    else
      render 'edit_password'
    end
  end

  def update
    account_update_params = registration_params

    # required for settings form to submit when password is left blank
    if account_update_params[:password].blank?
      account_update_params.delete('password')
      account_update_params.delete('password_confirmation')
    end

    @user = User.find(current_user.id)
    if @user.update_attributes(account_update_params)
      set_flash_message :notice, :updated
      sign_in @user, bypass: true
      redirect_to user_profile_url(subdomain:@user.username)
    else
      flash[:error] = @user.errors.full_messages.to_sentence
      render 'edit'
    end
  end

  # Finish registration fields edit/update
  def finish_registration
    if request.patch? && params[:user] && params[:user][:username]
      update_params = registration_params
      update_params[:finished_registration?] = true
      update_params[:sheet_quota] = User::BASIC_FREE_SHEET_QUOTA
      if current_user.update(update_params)
        UserMailer.welcome_email(current_user).deliver
        track('Finished registration')
        redirect_to user_profile_url(subdomain: current_user.username), notice: SUCCESS_UPDATE_PROFILE_MESSAGE
      else
        flash[:error] = current_user.errors.full_messages.to_sentence
        redirect_to finish_registration_url, error: FAILURE_UPDATE_PROFILE_MESSAGE
      end
    else
      # Render Form
    end
  end

  def destroy
    # Disable destroy
    p 'Accounts cannot be deleted'
  end

  protected

  def validate_user_signed_in
    redirect_to new_user_session_url unless user_signed_in?
  end

  def disable_for_omniauth
    return unless current_user.provider?
    flash[:error] = 'Users logged in via Facebook/Google+ cannot change their password'
    redirect_to :back
  end

  def set_current_user
    @user = current_user
  end

  def set_profile_user
    @user = User.find_by('username = ?', request.subdomain.downcase) || not_found
  end

  def registration_params
    params[:user].permit(:username, :finished_registration?, :tagline, :website,
                         :avatar, :terms, :paypal_email, :first_name,
                         :last_name, :sheet_quota, :timezone,
                         :billing_full_name, :billing_address_line_1,
                         :billing_address_line_2, :billing_city,
                         :billing_state_province, :billing_country,
                         :billing_zipcode, :facebook_username,
                         :twitter_username, :googleplus_username,
                         :soundcloud_username, :youtube_username)
  end

  def password_params
    params[:user].permit(:current_password, :password, :password_confirmation)
  end

  def downcase_username
    params[:username] = params[:username].downcase
  end

  def validate_registration_finished
    finished = !user_signed_in? || current_user.finished_registration?
    if (params[:action] == 'finish_registration') && finished
      redirect_to root_url
    end
  end

  def validate_has_published
    redirect_to root_url, notice: PUBLISHER_ONLY_FEATURE_MESSAGE unless current_user.has_published
  end
end