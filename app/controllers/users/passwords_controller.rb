class Users::PasswordsController < Devise::PasswordsController
  has_mobile_fu
  
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
  
  # OVERRIDE METHODS
  
  # PUT /resource/password
   def update
     self.resource = User.reset_password_by_token(params[:user])

     if resource.errors.empty?
       flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
       set_flash_message(:notice, flash_message) if is_navigational_format?
       sign_in(resource_name, resource)
       if(in_mobile_view?)
         render :finish_reset
       else
         respond_with resource, :location => after_sign_in_path_for(resource)
        end
     else
       if(in_mobile_view?)
         render :action => :edit
       else
         respond_with resource
       end
     end
   end

  protected

  def set_current_tab
    @current_tab = "account"
  end
end
