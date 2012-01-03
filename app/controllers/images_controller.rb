class ImagesController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource
  
  def index
    @gallery = current_user.galleries.find_by_id(params[:gallery_id])
    
    if request.xhr?  
      list = @gallery.images.all
      images = list.map { |image| 
        { :name => image.name,
          :size => image.data_file_size,
          :url => image.data.url,
          :thumbnail_url => image.data(:thumb),
          :delete_url => "/galleries/#{@gallery.id}/images/delete/#{image.id}",
          :edit_url => url_for(:controller => 'images', :action => 'edit', :id => image.id)
        } 
      }
      render :json => images
    else
      @images = @gallery.images.load_images(@filtered_params)
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
        :size => image.data_file_size,
        :url => image.data.url,
        :thumbnail_url => image.data(:thumb),
        :delete_url => "/galleries/#{@gallery.id}/images/delete/#{image.id}",
        :edit_url => url_for(:controller => 'images', :action => 'edit', :id => image.id)
#        :delete_type => "DELETE"
      }]
    end

    render :json => result
  end
  
  def destroy
    Image.destroy params[:id]
    redirect_to :action => :list
  end
  
  def list
    @gallery = Gallery.find_by_id(params[:gallery_id])
    @images = @gallery.images.find :all
  end
  
  def show
    @post = Image.paginate(:page => 1, :per_page => 5)
  end
  
  def edit
    @image = Image.find_by_id params[:id]
  end
  
  def update
    image = Image.find_by_id params[:id]
    image.update_attributes params[:image]
    redirect_to :action => :list
  end
  
  # GET images/slideshow
  # params: id => Image ID
  def slideshow
    # get selected Image
    @selectedImage = Image.find_by_id(params[:id])
    if (@selectedImage.nil?)
      return 
    end
    # get Gallery
    @images = @selectedImage.gallery.images
    # get Images belongs Gallery
  end
  
  protected
  
  def set_current_tab
    @current_tab = "galleries"
  end
end
