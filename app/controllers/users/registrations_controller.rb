class Users::RegistrationsController < Devise::RegistrationsController
  layout 'main'
  before_filter :get_invitation, :only => [:new, :create]
  skip_before_filter :authenticate_user!

  def new
    super
  end

  def create
    super
  end

  def update
    super
  end

  protected

  def get_invitation
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
