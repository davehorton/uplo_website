class ImagesController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource
  
  def index
    if find_gallery!
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

    render :text => result.to_json
  end
  
  def destroy
    ids = params[:id]
    ids = params[:id].join(',') if params[:id].instance_of? Array
    Image.destroy_all("id in (#{ids})")
    render :json => {:success => true}
  end
  
  def list
    if find_gallery!
      @images = @gallery.images.load_images(@filtered_params)
      @page_id = @filtered_params[:page_id].nil? ? 1 : @filtered_params[:page_id]
      @page_size = @filtered_params[:page_size]
    end
  end
    
  # GET images/:id/slideshow
  # params: id => Image ID
  def show
    # get selected Image
    @selected_image = Image.find_by_id(params[:id])
    if (@selected_image.nil?)
      return render_not_found
    end
    # get Gallery
    @images = @selected_image.gallery.images.all(:order => 'id')
    # get Images belongs Gallery
  end
  
  # GET images/:id/browse
  def browse
    @image = Image.find_by_id(params[:id])
    if @image.blank?
      return render_not_found
    elsif @image.gallery && !@image.gallery.can_access?(current_user)
      return render_unauthorized
    end
    @images = @image.gallery.images.all(:order => 'name')
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
    tab = "galleries"
    if params[:action] == "browse"
      tab = "browse"
    end
    
    @current_tab = tab
  end
  
  def default_page_size
    return 12
  end
  
  def find_gallery
    @gallery = Gallery.find_by_id(params[:gallery_id])
  end
  
  def find_gallery!
    self.find_gallery
    if @gallery.blank?
      render_not_found
      return false
    elsif !@gallery.can_access?(current_user) || 
          (!@gallery.is_owner?(current_user) && %w(edit update destroy create list).include?(params[:action]))
      render_unauthorized
      return false
    end
    @gallery
  end
end
