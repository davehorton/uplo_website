class Users::RegistrationsController < Devise::RegistrationsController
  layout 'main'

  def new
    if Invitation.exists?({:token => params[:token]})
      @inv  = Invitation.find_by_token params[:token]
      super
    elsif GalleryInvitation.exists?({:id => params[:id]})
      @inv  = GalleryInvitation.find_by_id params[:id]
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
    elsif GalleryInvitation.exists?({:id => params[:id]})
      @inv  = GalleryInvitation.find_by_id params[:id]
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
    session[:user_return_to].nil? ? root_url : session[:user_return_to]
  end

  def after_inactive_sign_up_path_for(resource)
    session[:user_return_to].nil? ? root_url : session[:user_return_to]
  end

end
