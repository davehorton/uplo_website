class Api::UsersController < ApplicationController
#  before_filter :authenticate_user!, :only => [:login]
  
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
      :auth_token => ''
    }
    user = User.find_by_username params[:login]
    if user.nil?
      result[:msg] = 'User does not exist'
    elsif not user.confirmed?
      result[:msg] = "You must confirm your registration first"
    elsif not user.valid_password?(params[:password])
      result[:msg] = "Password is not correct"
    else
      info = user.attributes()
      info[:avatar_url] = user.avatar.url
      result[:user_info] = info
      session[:user_id] = user.id
      user.ensure_authentication_token!
      result[:auth_token] = user.authentication_token
      result[:success] = true
    end
    
    render :json => result
  end
  
  def logout
    result = {:success => false}
    user = current_user
    user.authentication_token = nil unless user.nil?
    if !user.nil? && user.save? 
      session[:user_id] = nil
      result[:success] = true
    end
    render :json =>result
  end
  
  def reset_password
    User.send_reset_password_instructions({:email => params[:email]}) 
  end
end
