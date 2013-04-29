class Users::RegistrationsController < Devise::RegistrationsController
  layout 'main'
  before_filter :find_invitation, :only => [:new, :create]

  def new
    if @inv
      super
    else
      flash[:info] = 'Please login.'
      redirect_to '/'
    end
  end

  def create
    if @inv
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

  def find_invitation
    @inv = if params[:token].present?
             Invitation.find_by_token params[:token]
           elsif params[:secret_token].present?
             GalleryInvitation.find_by_secret_token(params[:secret_token])
           end
  end

  def after_sign_up_path_for(resource)
    super(resource)
  end

end
