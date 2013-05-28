class Users::SessionsController < Devise::SessionsController
  skip_before_filter(:authenticate_user!)
  skip_authorization_check

  # GET /resource/sign_in
  def new
    session[:devise_message] = flash[:alert]
  end

  def create
    super
    # Clear the flash
    flash.clear
  end

  def destroy
    super
    # Clear the flash
    flash.clear
  end
end
