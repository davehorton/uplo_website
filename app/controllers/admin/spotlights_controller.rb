class Admin::SpotlightsController < Admin::AdminController
  self.per_page = 12

  def index
    @sort_field = params[:sort_field] || "date_uploaded"
    @sort_direction = params[:sort_direction] || "asc"
    @images = Image.public_access.with_gallery.paginate_and_sort(filtered_params.merge(
      :sort_field => @sort_field,
      :sort_direction => @sort_direction
    ))
  end

  def search
    @images = Image.search_scope(params[:admin_query]).paginate_and_sort(filtered_params)
    render 'admin/spotlights/index'
  end

  # POST: /admin/spotlights/:id/promote
  # Ajax method.
  def promote
    image = Image.unflagged.find_by_id(params[:id])

    result = {}

    if image
      if params[:demote]
        method = :demote!
      else
        method = :promote!

        Notification.deliver_spotlight_notification(image, Notification::TYPE[:spotlight])
      end

      if image.send(method)
        result[:status] = 'ok'
        result[:message] = I18n.t("admin.notice_#{method}_succeeded")
      else
        result[:status] = 'error'
        result[:message] = I18n.t("admin.error_#{method}_failed")
      end
    else
      result[:status] = 'error'
      result[:message] = I18n.t("admin.error_image_not_found")
    end

    render(:json => result)
  end

  def clear_all
    Image.demote_all!
    redirect_to admin_spotlights_path, notice: "Spotlights cleared!"
  end

  protected

    def set_current_tab
      @current_tab = "spotlights"
    end
end
