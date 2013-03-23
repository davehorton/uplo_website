class Users::RegistrationsController < Devise::RegistrationsController
  layout 'main'

  def new
    if Invitation.exists?({:token => params[:token]})
      @inv  = Invitation.find_by_token params[:token]
      super
    else
      flash[:info] = 'Please login.'
      redirect_to '/'
    end
  end

  def create
    if Invitation.exists?({:token => params[:token]})
      @inv  = Invitation.find_by_token params[:token]
      super
    else
      flash[:info] = 'Invalid invitation!'
      redirect_to '/'
    end
  end

  def update
    super
  end

  protected

  def after_sign_up_path_for(resource)
    #'/my_account'
    super(resource)
  end
end
