class UsersController < ApplicationController
  before_filter :authenticate_user!
  
  def profile
    @user = current_user
  end
  
  def edit
    @user = current_user
  end
  
  def update
    @user = current_user
    respond_to do |format|
      if @user.update_profile(params[:user])
        format.html { redirect_to("/profile", :notice => I18n.t('user.update_done')) }
      else
        format.html { render :action => "edit", :notice => @user.errors}
      end
    end
  end
  
  def set_current_tab
    @current_tab = "account"
  end
end
