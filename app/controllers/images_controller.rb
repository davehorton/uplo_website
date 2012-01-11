class ImagesController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource
  
  def index
    @gallery = Gallery.find_by_id(params[:gallery_id])
    @images = @gallery.images.load_images(@filtered_params)
    
    if request.xhr?
      @images = @images.map { |image| 
        { :name => image.name,
          :description => image.description,
          :size => image.data_file_size,
          :url => image.data.url,
          :thumbnail_url => image.data(:thumb),
          :delete_url => "/galleries/#{@gallery.id}/images/delete/#{image.id}",
          :edit_url => url_for(:controller => 'images', :action => 'show', :id => image.id),
          :image_id => image.id
        } 
      }
      render :json => @images
    end    
  end 
  
  def new 
  end
  
  def create
    data = params[:image][:data]
    image_info = {
      :name => data[0].original_filename,
      :gallery_id => params[:gallery_id],
      :data => data[0]
    }

    image = Image.new image_info
    unless image.save
      result = [{:error => 'Cannot save image' }]
    else
      result = [{
        :name => image.name,
        :description => image.description,
        :size => image.data_file_size,
        :url => image.data.url,
        :thumbnail_url => image.data(:thumb),
        :delete_url => "/galleries/#{params[:gallery_id]}/images/delete/#{image.id}",
        :edit_url => url_for(:controller => 'images', :action => 'show', :id => image.id),
        :image_id => image.id
      }]
    end

    render :json => result
  end
  
  def destroy
    ids = params[:id]
    ids = params[:id].join(',') if params[:id].instance_of? Array
    Image.destroy_all("id in (#{ids})")
    render :json => {:success => true}
  end
  
  def list
    @gallery = Gallery.find_by_id(params[:gallery_id])
    @images = @gallery.images.load_images(@filtered_params)
    @page_id = @filtered_params[:page_id].nil? ? 1 : @filtered_params[:page_id]
  end
    
  # GET images/:id/slideshow
  # params: id => Image ID
  def show
    # get selected Image
    @selected_image = Image.find_by_id(params[:id])
    if (@selected_image.nil?)
      return render 'public/404.html'
    end
    # get Gallery
    @images = @selected_image.gallery.images.all(:order => 'id')
    # get Images belongs Gallery
  end
  
  # PUT images/:id/slideshow_update
  # params: id => Image ID
  def update
    image = Image.find_by_id params[:id]
    image.update_attributes params[:image]
    redirect_to :action => :show, :id => params[:id]
  end
  
  protected
  
  def set_current_tab
    @current_tab = "galleries"
  end
  
  def default_page_size
    return 12
  end
end
