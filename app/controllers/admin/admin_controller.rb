class Admin::AdminController < ApplicationController
  layout "main"
  
  before_filter :authenticate_admin_user!
  
  def index
    redirect_to '/admin/flagged_images'
  end
  
  protected
  
  # TODO: should define authorization in Cancan Ability.
  def authenticate_admin_user!
    authenticate_user!
    # Check Admin
    if current_user.blank? || !current_user.is_admin?
      raise CanCan::AccessDenied
    end
  end
  
  def set_current_tab
    @current_tab = "flagged_images"
  end
  
end
