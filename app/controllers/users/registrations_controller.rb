class Users::RegistrationsController < Devise::RegistrationsController


  # GET /user/:username
  def profile
    @user = User.find_by(username: params[:username])
  end

  # GET /resource/edit
  def edit
    redirect_to root_path
    # binding.pry
    # Disallow users from editing their account details i.e. email, username
  end


end