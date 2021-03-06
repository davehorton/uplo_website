class Users::PasswordsController < Devise::PasswordsController
  skip_before_filter :authenticate_user!, except: [:edit_password, :update_password]

  def update_password
    if current_user.update_profile(params[:user])
      sign_in(current_user, :bypass => true)
      redirect_to("/my_account", :notice => I18n.t('user.update_password_done'))
    else
      render :action => :edit_password
    end
  end

  def update
    self.resource = User.reset_password_by_token(params[:user])

    if resource.errors.empty?
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:notice, flash_message) if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with resource, :location => after_sign_in_path_for(resource)
    else
      respond_with resource
    end
  end

  protected

    def set_current_tab
      @current_tab = "account"
    end
end
