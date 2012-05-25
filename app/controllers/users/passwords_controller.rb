class Users::PasswordsController < Devise::PasswordsController
  prepend_before_filter :require_no_authentication, :except => [:edit_password, :update_password]
  before_filter :authenticate_user!, :only => [:edit_password, :update_password]

  def edit_password
    @user = current_user
  end

  def update_password
    @user = current_user
    if @user.update_profile(params[:user])
      sign_in(@user, :bypass => true)
      redirect_to("/my_account", :notice => I18n.t('user.update_password_done'))
    else
      render :action => :edit_password
    end
  end

  protected

  def set_current_tab
    @current_tab = "account"
  end
end
