class Users::RegistrationsController < Devise::RegistrationsController
  def new
    if Invitation.exists?({:token => params[:token]})
      @inv  = Invitation.find_by_token params[:token]
      super
    end
  end

  def create
    super
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
