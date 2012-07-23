class Admin::SpotlightsController < Admin::AdminController
  def index
    @sort_field = params[:sort_field] || "date_uploaded"
    @images = Image.public_images.load_images(filtered_params.merge(:sort_field => @sort_field))
  end
  
  def search
    search_params = {:query => URI.unescape(params[:query]), :filtered_params => filtered_params}
    @images = Image.public_images.do_search(search_params)
    render 'admin/spotlights/index'
  end
  
  # POST: /admin/spotlights/:id/promote
  # Ajax method.
  def promote
    image = Image.find_by_id(params[:id])
    result = {}
    if image
      if image.promote
        result[:status] = 'ok'
        result[:message] = I18n.t("admin.notice_promote_succeeded")
      else
        result[:status] = 'error'
        result[:message] = I18n.t("admin.error_promote_failed")
      end
    else
      result[:status] = 'error'
      result[:message] = I18n.t("admin.error_image_not_found")
    end
    
    render(:json => result)
  end
  
  protected
  
  def select_tab
    @current_tab = "spotlights"
  end
end
