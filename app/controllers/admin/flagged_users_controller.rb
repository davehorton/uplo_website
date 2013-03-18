class Admin::FlaggedUsersController < Admin::AdminController
  def index
    @users = User.flagged_users.paginate_and_sort(self.filtered_params)
  end

  # TODO: optimize this method
  def reinstate_all
    result = {}

    begin
      if User.reinstate_flagged_users
        result[:status] = 'ok'
        flash[:notice] = I18n.t("admin.notice_reinstate_users_succeeded")
        result[:redirect_url] = admin_flagged_users_path
      else
        result[:status] = 'error'
        result[:message] = I18n.t("admin.error_reinstate_users_failed")
      end
    rescue User::NotReadyForReinstatingError
      result[:status] = 'error'
      result[:message] = I18n.t("admin.error_not_ready_for_reinstating")
    rescue Exception => exc
      ::Util.log_error(exc, "Admin::FlaggedUsersController#reinstate_all")
      result[:status] = 'error'
      result[:message] = I18n.t("admin.error_reinstate_users_failed")
    end

    render(:json => result)
  end

  # TODO: optimize this method
  def remove_all
    result = {}

    begin
      if User.remove_flagged_users
        result[:status] = 'ok'
        flash[:notice] = I18n.t("admin.notice_remove_users_succeeded")
        result[:redirect_url] = admin_flagged_users_path
      else
        result[:status] = 'error'
        result[:message] = I18n.t("admin.error_remove_users_failed")
      end
    rescue User::NotReadyForReinstatingError
      result[:status] = 'error'
      result[:message] = I18n.t("admin.error_not_ready_for_removing")
    rescue Exception => exc
      ::Util.log_error(exc, "Admin::FlaggedUsersController#remove_all")
      result[:status] = 'error'
      result[:message] = I18n.t("admin.error_reinstate_users_failed")
    end

    render(:json => result)
  end

  # Reinstate all flagged images of a user.
  def reinstate_user
    result = {}

    begin
      user = User.find_by_id(params[:id])

      if user
        if user.reinstate
          result[:status] = 'ok'
          flash[:notice] = I18n.t("admin.notice_reinstate_user_succeeded")
          result[:redirect_url] = admin_flagged_users_path
        else
          result[:status] = 'error'
          result[:message] = I18n.t("admin.error_reinstate_user_failed")
        end
      else
        result[:status] = 'error'
        result[:message] = I18n.t("admin.error_user_not_found")
      end
    rescue User::NotReadyForReinstatingError
      result[:status] = 'error'
      result[:message] = I18n.t("admin.error_not_ready_for_reinstating")
    rescue Exception => exc
      ::Util.log_error(exc, "Admin::FlaggedUsersController#reinstate_user")
      result[:status] = 'error'
      result[:message] = I18n.t("admin.error_reinstate_users_failed")
    end

    render(:json => result)
  end

  # Remove all flagged images of a user.
  def remove_user
    result = {}

    begin
      user = User.find_by_id(params[:id])

      if user
        if user.id == current_user.id
          result[:status] = 'error'
          result[:message] = I18n.t("admin.error_remove_myself")
        else
          if user.remove
            result[:status] = 'ok'
            result[:message] = I18n.t("admin.notice_remove_user_succeeded")
          else
            result[:status] = 'error'
            result[:message] = I18n.t("admin.error_remove_user_failed")
          end
        end
      else
        result[:status] = 'error'
        result[:message] = I18n.t("admin.error_user_not_found")
      end

    rescue User::NotReadyForReinstatingError
      result[:status] = 'error'
      result[:message] = I18n.t("admin.error_not_ready_for_removing")
    rescue Exception => exc
      ::Util.log_error(exc, "Admin::FlaggedUsersController#remove_user")
      result[:status] = 'error'
      result[:message] = I18n.t("admin.error_reinstate_users_failed")
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
