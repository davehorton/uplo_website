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
    if params[:token].present?
      @inv = Invitation.find_by_token params[:token]
      @email = @inv.try(:email)
    elsif params[:secret_token].present?
      @inv = GalleryInvitation.find_by_secret_token(params[:secret_token])
      @email = @inv.try(:emails)
    end
  end

  def after_sign_up_path_for(resource)
    super(resource)
  end

end
