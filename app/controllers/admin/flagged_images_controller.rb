class Admin::FlaggedImagesController < Admin::AdminController
  self.page_size = 12

  respond_to :json, only: [:reinstate_all, :remove_all, :reinstate_image, :remove_image, :get_image_popup]

  def index
    if (params[:flag_type].nil?)
      params[:flag_type] = 1
    end
    @flagged_images = Image.flagged.where("flag_type = ?", params[:flag_type]).with_gallery.paginate_and_sort(filtered_params)
  end

  def reinstate_all
    result = {}
    users = []

    begin
      Image.flagged.where(flag_type: params[:flag_type]).each do |image|
        if image.reinstate
          users << image.author_id
        end
      end

      ImageFlag.send_reinstated_email(users.uniq) unless users.blank?

      result[:status] = 'ok'
      flash[:notice] = I18n.t("admin.notice_reinstate_images_succeeded")
      result[:redirect_url] = admin_flagged_images_path(:flag_type => params[:flag_type])

    rescue Exception => exc
      ::Util.log_error(exc, "Admin::FlaggedImagesController#reinstate_all")
      result[:status] = 'error'
      result[:message] = I18n.t("admin.error_reinstate_images_failed")
    end

    respond_with result
  end

  def remove_all
    result = {}
    users = []

    begin
      Image.flagged.where(flag_type: params[:flag_type]).each do |image|
        if image.update_attribute(:removed, true)
          users << image.author_id
        end
      end

      ImageFlag.send_image_removed_email(users.uniq) unless users.blank?

      result[:status] = 'ok'
      flash[:notice] = I18n.t("admin.notice_remove_images_succeeded")
      result[:redirect_url] = admin_flagged_images_path(:flag_type => params[:flag_type])

    rescue Exception => exc
      ::Util.log_error(exc, "Admin::FlaggedImagesController#remove_all")
      result[:status] = 'error'
      result[:message] = I18n.t("admin.error_remove_images_failed")
    end

    respond_with result
  end

  def reinstate_image
    result = {}

    begin
      image = Image.flagged.find_by_id(params[:image_id])
      if image && image.reinstate
        UserMailer.delay.flagged_image_reinstated_email(image.author_id, image)
        result[:status] = 'ok'
        flash[:notice] = I18n.t("admin.notice_reinstate_image_succeeded")
        result[:redirect_url] = admin_flagged_images_path(:flag_type => params[:flag_type])
      else
        result[:status] = 'error'
        result[:message] = I18n.t("admin.error_reinstate_image_failed")
      end
    rescue Exception => exc
      ::Util.log_error(exc, "Admin::FlaggedImagesController#remove_all")
      result[:status] = 'error'
      result[:message] = I18n.t("admin.error_reinstate_image_failed")
    end

    respond_with result
  end

  def remove_image
    result = {}

    begin
      image = Image.flagged.find_by_id(params[:image_id])
      if image && image.update_attribute(:removed, true)
        UserMailer.delay.flagged_image_removed_email(image.author_id, image)
        result[:status] = 'ok'
        flash[:notice] = I18n.t("admin.notice_remove_image_succeeded")
        result[:redirect_url] = admin_flagged_images_path(:flag_type => params[:flag_type])
      else
        result[:status] = 'error'
        result[:message] = I18n.t("admin.error_remove_image_failed")
      end
    rescue Exception => exc
      ::Util.log_error(exc, "Admin::FlaggedImagesController#remove_all")
      result[:status] = 'error'
      result[:message] = I18n.t("admin.error_remove_image_failed")
    end

    respond_with result
  end

  def get_image_popup
    image = Image.flagged.find_by_id(params[:image_id])
     result = {
        :success => false,
        :msg => ""
      }
    if (image && image.image_flags.count > 0)
      result[:success] = true
      result[:data] = render_to_string :partial => "admin/flagged_images/flagged_image_popup", :locals => {:flag => image.image_flags.first}

    else
      result[:success] = false
      result[:msg] = "The image is not available or not flagged"
    end

    respond_with result
  end

  protected

    def set_current_tab
      @current_tab = "flagged_images"
    end
end
