class Api::UsersController < ApplicationController
#  before_filter :authenticate_user!, :only => [:login]
  
  def create_user
    info = params
    user = User.new info
    result = {
      :success => true,
      :msg => {}
    }
    unless user.save
      result[:msg] = user.errors 
      result[:success] = false
    end
    render :json => { :info => result }
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
      result[:auth_token] = user.ensure_authentication_token!
    end
    
    render :json => { :info => result }
  end
  
  def logout
    user = current_user
    user.authentication_token = nil
    result[:success] = @user.save ? true : false
    
    render :json => { :info => result }
  end
end
