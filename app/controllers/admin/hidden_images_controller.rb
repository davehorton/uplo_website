class Admin::HiddenImagesController < Admin::AdminController
 self.per_page = 12

  def index
    @sort_field = params[:sort_field] || "date_uploaded"
    @sort_direction = params[:sort_direction] || "asc"
    @images = Image.public_access.with_gallery.paginate_and_sort(filtered_params.merge(:sort_field => @sort_field, :sort_direction => @sort_direction ))
  end

  def toggle_hidden_by_admin
    @image = Image.find(params[:id])
    @image.toggle!(:hidden_by_admin)
    redirect_to browse_image_path(@image) unless request.xhr?
  end

  protected

    def set_current_tab
      @current_tab = "hidden_images"
    end
end
