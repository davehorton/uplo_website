class Admin::AdminController < ApplicationController
  before_filter :authenticate_admin_user!
  around_filter :apply_user_scope
  layout "admin"

  def index
    redirect_to '/admin/flagged_images'
  end

  protected

  # TODO: should define authorization in Cancan Ability.
  def authenticate_admin_user!
    authenticate_user!
    # Check Admin
    if current_user.blank? || !current_user.admin?
      raise CanCan::AccessDenied
    end
  end

  def set_current_tab
    @current_tab = "flagged_images"
  end

end
