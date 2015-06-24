class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  [:google_oauth2, :facebook].each do |provider|
    define_method(:provider) do
      @user = User.from_omniauth(request.env['omniauth.auth'])
      if @user.persisted?
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: provider.titleize) if is_navigational_format?
      else
        flash[:error] = @user.errors.empty? ? 'Error' : @user.errors.full_messages.to_sentence
        redirect_to new_user_registration_url
      end
    end
  end
end