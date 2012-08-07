class Users::SessionsController < Devise::SessionsController
  #ssl_required :sign_in, :new, :create if ssl_required?

  skip_before_filter(:authenticate_user!)
  skip_authorization_check
  layout false

  def set_current_tab
    # bypass this method since login page does not contains any tabs
  end

  def new
    flash[:info] = 'You have to sign in first!'
    redirect_to '/'
  end

  # POST /resource/sign_in
  def create
    super
  end
end
