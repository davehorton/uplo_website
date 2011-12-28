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
    result = { :success => false }
    user = User.find_by_username params[:login]
    if user.nil?
      result[:msg] = 'User does not exist'
    elsif user.confirmed?
      result[:msg] = "You must confirm your registration first"
    elsif not user.valid_password?(params[:password])
      result[:msg] = "Password is not correct"
    else
      session[:user_id] = user.id
      result[:success] = true
      user.ensure_authentication_token!
      result[:auth_token] = user.authentication_token
      result[:user_info] = user.attributes()
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
