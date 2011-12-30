class ImagesController < ApplicationController
  before_filter :authenticate_user!
  
  def slideshow
  end
  
  def index
    list = Image.all
    list.map! { |image| 
      { :name => image.name,
        :size => image.data_file_size,
        :url => url_for(:controller => 'images', :action => 'edit', :id => image.id),
        :thumbnail_url => image.data(:thumb),
        :delete_url => "/images/delete/#{image.id}"
      } 
    }
    render :json => list
  end 
  
  def new 
  end
  
  def create
    info = params[:image]
    a = {
      :name => info[0].original_filename,
      :gallery_id => 1,
      :data => info
    }

    image = Image.new a
    unless image.save
      result = [{:error => 'Cannot save image' }]
    else
      result = [{
        :name => image.name,
        :size => image.data_file_size,
        :url => url_for(:controller => 'images', :action => 'edit', :id => image.id),
        :thumbnail_url => image.data(:thumb),
        :delete_url => "/images/delete/#{image.id}"
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
  end
  
  def show
  end
  
  def edit
    @image = Image.find_by_id params[:id]
  end
  
  def update
    image = Image.find_by_id params[:id]
    image.update_attributes params[:image]
    redirect_to :action => :list
  end
  
  protected
  
  def set_current_tab
    @current_tab = "galleries"
  end
end
