class Users::SessionsController < Devise::SessionsController
  skip_before_filter(:authenticate_user!)
  skip_authorization_check

  def index
    super
    @authentications = current_user.authentications if current_user
  end

  # GET /resource/sign_in
  def new
    session[:devise_message] = flash[:alert]

    # GET /resource/sign_up
    build_resource({})
    respond_with self.resource
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
