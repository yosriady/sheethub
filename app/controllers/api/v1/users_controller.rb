class API::V1::UsersController < ApplicationController
  respond_to :json
  before_action :restrict_access

  def index
    @users = User.all
    respond_with @users
  end

  def show
    if params[:id].to_i.to_s == params[:id]
      @user = User.find(params[:id])
    else
      @user = User.find_by('username = ?', params[:id])
    end
    respond_with @user
  end
end
