class ImagesController < ApplicationController
  before_filter :authenticate_user!
  
  def slideshow
  end
  
  def index
  
  end 
  
  def new 
  end
  
  def create
    @upload = Image.new(params[:upload])
    if @upload.save
      render :json => { :pic_path => @upload.data.url.to_s , :name => @upload.data.instance.attributes["picture_file_name"] }, :content_type => 'text/html'
    else
      render :json => { :result => 'error'}, :content_type => 'text/html'
    end
  end
  
  def upload
    info = params[:image]
    a = {
      :name => 'alaalla',
      :gallery_id => 1,
      :data => info
    }

    image = Image.new a
    unless image.save
      result = [{:error => 'Cannot save image' }]
    else
      result = [{
        :name => image.data_file_name,
        :size => image.data_file_size,
        :url => image.data.url,
        :thumbnail_url => image.data(:thumb)
#        :delete_url
#        :delete_type => "DELETE"
      }]
    end

    render :json => result
  end
  
  def show
  end
  
  def list
  end
end
