class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def google_oauth2
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: 'Google') if is_navigational_format?
    else
      # session['devise.google_data'] = request.env['omniauth.auth']
      flash[:error] = @user.errors.empty? ? 'Error' : @user.errors.full_messages.to_sentence
      redirect_to new_user_registration_url
    end
  end

  def facebook
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: 'Facebook') if is_navigational_format?
    else
      # session['devise.facebook_data'] = request.env['omniauth.auth'].except('extra')
      flash[:error] = @user.errors.empty? ? 'Error' : @user.errors.full_messages.to_sentence
      redirect_to new_user_registration_url
    end
  end

end