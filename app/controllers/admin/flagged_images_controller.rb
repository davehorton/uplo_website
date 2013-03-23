class Admin::FlaggedImagesController < Admin::AdminController
  self.page_size = 12

  def index
    @flagged_images = Image.flagged_of_type(params[:flag_type]).with_gallery.paginate_and_sort(filtered_params)
  end

  def reinstate_all
    begin
      Image.reinstate_all_flagged_images(params[:flag_type])
      result_hash[:status] = 'ok'
      flash[:notice] = I18n.t("admin.notice_reinstate_images_succeeded")
      result_hash[:redirect_url] = admin_flagged_images_path(:flag_type => params[:flag_type])

    rescue Exception => exc
      ExternalLogger.new.log_error(exc, "Admin::FlaggedImagesController#reinstate_all", params)
      result_hash[:status] = 'error'
      result_hash[:message] = I18n.t("admin.error_reinstate_images_failed")
    end

    render json: result_hash
  end

  def remove_all
    begin
      Image.remove_all_flagged_images(params[:flag_type])
      result_hash[:status] = 'ok'
      flash[:notice] = I18n.t("admin.notice_remove_images_succeeded")
      result_hash[:redirect_url] = admin_flagged_images_path(:flag_type => params[:flag_type])

    rescue Exception => exc
      ExternalLogger.new.log_error(exc, "Admin::FlaggedImagesController#remove_all", params)
      result_hash[:status] = 'error'
      result_hash[:message] = I18n.t("admin.error_remove_images_failed")
    end

    render json: result_hash
  end

  def reinstate_image
    begin
      image = Image.flagged.find_by_id(params[:image_id])
      if image && image.reinstate!
        result_hash[:status] = 'ok'
        flash[:notice] = I18n.t("admin.notice_reinstate_image_succeeded")
        result_hash[:redirect_url] = admin_flagged_images_path(:flag_type => params[:flag_type])
      else
        result_hash[:status] = 'error'
        result_hash[:message] = I18n.t("admin.error_reinstate_image_failed")
      end
    rescue Exception => exc
      ExternalLogger.new.log_error(exc, "Admin::FlaggedImagesController#reinstate_image", params)
      result_hash[:status] = 'error'
      result_hash[:message] = I18n.t("admin.error_reinstate_image_failed")
    end

    render json: result_hash
  end

  def remove_image
    begin
      image = Image.flagged.find_by_id(params[:image_id])
      if image && image.remove!
        result_hash[:status] = 'ok'
        flash[:notice] = I18n.t("admin.notice_remove_image_succeeded")
        result_hash[:redirect_url] = admin_flagged_images_path(:flag_type => params[:flag_type])
      else
        result_hash[:status] = 'error'
        result_hash[:message] = I18n.t("admin.error_remove_image_failed")
      end
    rescue Exception => exc
      ExternalLogger.new.log_error(exc, "Admin::FlaggedImagesController#remove_image", params)
      result_hash[:status] = 'error'
      result_hash[:message] = I18n.t("admin.error_remove_image_failed")
    end

    render json: result_hash
  end

  def get_image_popup
    image = Image.flagged.find_by_id(params[:image_id])
    if (image && image.image_flags.count > 0)
      result_hash[:success] = true
      result_hash[:data] = render_to_string :partial => "admin/flagged_images/flagged_image_popup", :locals => {:flag => image.image_flags.first}

    else
      result_hash[:success] = false
      result_hash[:msg] = "The image is not available or not flagged"
    end

    render json: result_hash
  end

  protected

    def set_current_tab
      @current_tab = "flagged_images"
    end
end
