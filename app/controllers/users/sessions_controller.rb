class Users::SessionsController < Devise::SessionsController
  skip_before_filter(:authenticate_user!)
  skip_authorization_check

  # GET /resource/sign_in
  def new
    session[:devise_message] = flash.now[:alert]
    # Cleanup the flash
    flash.now[:alert] = nil
    redirect_to "/"
  end
end
