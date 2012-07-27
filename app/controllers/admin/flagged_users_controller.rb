class Admin::FlaggedUsersController < Admin::AdminController
  def index
    @users = User.flagged_users.load_users(self.filtered_params)
  end
  
  # TODO: optimize this method
  def reinstate_all
    result = {}
    
    if User.reinstate_flagged_users
      result[:status] = 'ok'
      result[:message] = I18n.t("admin.notice_reinstate_users_succeeded")
      result[:redirect_url] = admin_flagged_users_path
    else
      result[:status] = 'error'
      result[:message] = I18n.t("admin.error_reinstate_users_failed")
    end
    
    render(:json => result)
  end
  
  # TODO: optimize this method
  def remove_all
    result = {}
    
    if User.remove_flagged_users
      result[:status] = 'ok'
      result[:message] = I18n.t("admin.notice_remove_users_succeeded")
      result[:redirect_url] = admin_flagged_users_path
    else
      result[:status] = 'error'
      result[:message] = I18n.t("admin.error_remove_users_failed")
    end
    
    render(:json => result)
  end
  
  # Reinstate all flagged images of a user.
  def reinstate_user
    user = User.find_by_id(params[:id])
    result = {}
    
    if user
      if user.reinstate
        result[:status] = 'ok'
        result[:message] = I18n.t("admin.notice_reinstate_user_succeeded")
        result[:redirect_url] = admin_flagged_users_path
      else
        result[:status] = 'error'
        result[:message] = I18n.t("admin.error_reinstate_user_failed")
      end
    else
      result[:status] = 'error'
      result[:message] = I18n.t("admin.error_user_not_found")
    end
    
    render(:json => result)
  end
  
  # Remove all flagged images of a user.
  def remove_user
    user = User.find_by_id(params[:id])
    result = {}
    
    if user
      if user.remove
        result[:status] = 'ok'
        result[:message] = I18n.t("admin.notice_remove_user_succeeded")
      else
        result[:status] = 'error'
        result[:message] = I18n.t("admin.error_remove_user_failed")
      end
    else
      result[:status] = 'error'
      result[:message] = I18n.t("admin.error_user_not_found")
    end
    
    render(:json => result)
  end
  
  protected
    def set_current_tab
      @current_tab = "flagged_users"
    end
    
    def default_page_size
      return 24
    end
end
