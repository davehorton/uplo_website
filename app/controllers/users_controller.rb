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
  
  def search
    @no_async_image_tag = true
    @users = User.search params[:query], :star => true, :page => params[:page_id], :per_page => default_page_size
  end
  
  def set_current_tab
    tab = "account"
    browse_actions = ["search"]
    unless browse_actions.index(params[:action]).nil?
      tab = "browse"
    end
    
    @current_tab = tab
  end
  
  protected
  def default_page_size
    return 12
  end
end
