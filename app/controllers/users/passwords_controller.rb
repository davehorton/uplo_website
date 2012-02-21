class Users::PasswordsController < ApplicationController
  include Devise::Controllers::InternalHelpers
  
  def new
    build_resource({})
    render_with_scope :new
  end
  
  def create
    self.resource = resource_class.send_reset_password_instructions(params[resource_name])

    if successfully_sent?(resource)
      respond_with({}, :location => new_session_path(resource_name))
    else
      respond_with_navigational(resource){ render_with_scope :new }
    end
  end
  
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
