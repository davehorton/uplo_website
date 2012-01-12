class Users::PasswordsController < ApplicationController
  def edit
    @user = current_user
  end
  
  def update
    @user = current_user
    if @user.update_profile(params[:user])
      sign_in(@user, :bypass => true)
      redirect_to("/profile", :notice => I18n.t('user.update_password_done')) 
    else
      render :action => :edit
    end
  end
  
  protected
  
  def set_current_tab
    @current_tab = "account"
  end
end
