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
    if user && user.valid_password?(params[:password])
      session[:user_id] = user.id
      result[:success] = true
      user.ensure_authentication_token!
      result[:auth_token] = user.authentication_token
    end
    
    render :json => result
  end
  
  def logout
    result = {:success => false}
    user = current_user
    user.authentication_token = nil unless user.nil?
    if !user.nil? && user.save? 
      result[:success] = true
    end
    render :json =>result
  end
end
