class Admin::SpotlightsController < Admin::AdminController
  def index
    @sort_field = params[:sort_field] || "date_uploaded"
    @sort_direction = params[:sort_direction] || "asc"
    @images = Image.un_flagged.public_images.load_images(filtered_params.merge(
      :sort_field => @sort_field,
      :sort_direction => @sort_direction
    ))
  end
  
  def search
    search_params = {:query => URI.unescape(params[:query]), :filtered_params => filtered_params}
    @images = Image.do_search_public_images(search_params)
    render 'admin/spotlights/index'
  end
  
  # POST: /admin/spotlights/:id/promote
  # Ajax method.
  def promote
    image = Image.un_flagged.find_by_id(params[:id])
    result = {}
    if image
      method = :promote
      if params[:demote]
        # Unpromote this image
        method = :demote
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
  
  protected
    
    def default_page_size
      return 12
    end
    
    def set_current_tab
      @current_tab = "spotlights"
    end
end
