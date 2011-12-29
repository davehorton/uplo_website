class Api::UsersController < ApplicationController
  before_filter :authenticate_user!, :only => [:get_user_info]
  include Devise::Controllers::InternalHelpers
  
  def get_user_info
    result = {:success => false}
    user = User.find_by_id params[:id]
    if user.nil?
      result[:msg] = "This user does not exist"
    else
      info = user.serializable_hash :only => [:id, :email, :first_name, :last_name, :username, :nationality, :birthday, :gender]
      info[:avatar] = user.avatar.url
      result[:user_info] = info
      result[:success] = true
    end
    render :json => result
  end
  
  def create_user
    info = params[:user]
    user = User.new info
    result = {
      :success => true,
      :msg => {}
    }
    
    unless user.save
      result[:msg] = user.errors 
      result[:success] = false
    end
    render :json => result
  end
  
  def login
    result = {
      :success => false,
    }
    # Modify to apply devise
    user = warden.authenticate!(:api)
    sign_in(:user, user)
    user.reset_authentication_token!
    # End of modification
    
    info = user.serializable_hash :only => [:id, :email, :first_name, :authentication_token, :last_name, :username, :nationality, :birthday, :gender]
    info[:avatar] = user.avatar.url
    result[:user_info] = info
    result[:success] = true
    render :json => result
  end
  
  def logout
    result = {:success => false}
    signed_in = signed_in?(:user)
    Devise.sign_out_all_scopes ? sign_out : sign_out(:user)
    if signed_in
      result[:msg] = :signed_out
      result[:success] = true
    end
    render :json =>result
  end
  
  def reset_password
    result = { :success => true }
    user = User.find_by_email params[:email]
    if user.nil?
      result[:success] = false
      result[:msg] = "Email does not exist"
    else
      User.send_reset_password_instructions({:email => params[:email]})
    end
    render :json =>result
  end
end
