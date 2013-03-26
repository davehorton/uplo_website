class Admin::FlaggedUsersController < Admin::AdminController
  self.per_page = 24

  def index
    @users = User.flagged_users.paginate_and_sort(self.filtered_params)
  end

  def reinstate_all
    begin
      if User.reinstate_flagged_users
        result_hash[:status] = 'ok'
        flash[:notice] = I18n.t("admin.notice_reinstate_users_succeeded")
        result_hash[:redirect_url] = admin_flagged_users_path
      else
        result_hash[:status] = 'error'
        result_hash[:message] = I18n.t("admin.error_reinstate_users_failed")
      end
    rescue User::NotReadyForReinstatingError
      result_hash[:status] = 'error'
      result_hash[:message] = I18n.t("admin.error_not_ready_for_reinstating")
    rescue Exception => exc
      ExternalLogger.new.log_error(exc, "Admin::FlaggedUsersController#reinstate_all", params)
      result_hash[:status] = 'error'
      result_hash[:message] = I18n.t("admin.error_reinstate_users_failed")
    end

    render json: result_hash
  end

  def remove_all
    begin
      if User.remove_flagged_users
        result_hash[:status] = 'ok'
        flash[:notice] = I18n.t("admin.notice_remove_users_succeeded")
        result_hash[:redirect_url] = admin_flagged_users_path
      else
        result_hash[:status] = 'error'
        result_hash[:message] = I18n.t("admin.error_remove_users_failed")
      end
    rescue User::NotReadyForReinstatingError
      result_hash[:status] = 'error'
      result_hash[:message] = I18n.t("admin.error_not_ready_for_removing")
    rescue Exception => exc
      ExternalLogger.new.log_error(exc, "Admin::FlaggedUsersController#remove_all", params)
      result_hash[:status] = 'error'
      result_hash[:message] = I18n.t("admin.error_reinstate_users_failed")
    end

    render json: result_hash
  end

  # Reinstate all flagged images of a user.
  def reinstate_user
    begin
      user = User.find_by_id(params[:id])

      if user
        if user.reinstate
          result_hash[:status] = 'ok'
          flash[:notice] = I18n.t("admin.notice_reinstate_user_succeeded")
          result_hash[:redirect_url] = admin_flagged_users_path
        else
          result_hash[:status] = 'error'
          result_hash[:message] = I18n.t("admin.error_reinstate_user_failed")
        end
      else
        result_hash[:status] = 'error'
        result_hash[:message] = I18n.t("admin.error_user_not_found")
      end
    rescue User::NotReadyForReinstatingError
      result_hash[:status] = 'error'
      result_hash[:message] = I18n.t("admin.error_not_ready_for_reinstating")
    rescue Exception => exc
      ExternalLogger.new.log_error(exc, "Admin::FlaggedUsersController#reinstate_user", params)
      result_hash[:status] = 'error'
      result_hash[:message] = I18n.t("admin.error_reinstate_users_failed")
    end

    render json: result_hash
  end

  # Remove all flagged images of a user.
  def remove_user
    begin
      user = User.find_by_id(params[:id])

      if user
        if user.id == current_user.id
          result_hash[:status] = 'error'
          result_hash[:message] = I18n.t("admin.error_remove_myself")
        else
          if user.remove!
            result_hash[:status] = 'ok'
            result_hash[:message] = I18n.t("admin.notice_remove_user_succeeded")
            result_hash[:redirect_url] = admin_members_path
          else
            result_hash[:status] = 'error'
            result_hash[:message] = I18n.t("admin.error_remove_user_failed")
          end
        end
      else
        result_hash[:status] = 'error'
        result_hash[:message] = I18n.t("admin.error_user_not_found")
      end

    rescue User::NotReadyForReinstatingError
      result_hash[:status] = 'error'
      result_hash[:message] = I18n.t("admin.error_not_ready_for_removing")
    rescue Exception => exc
      ExternalLogger.new.log_error(exc, "Admin::FlaggedUsersController#remove_user", params)
      result_hash[:status] = 'error'
      result_hash[:message] = I18n.t("admin.error_reinstate_users_failed")
    end

    render json: result_hash
  end

  protected

    def set_current_tab
      @current_tab = "flagged_users"
    end
end
