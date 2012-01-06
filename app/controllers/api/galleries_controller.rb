=begin
  create_table "galleries", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.string   "name",        :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
=end

class Api::GalleriesController < Api::BaseController
  before_filter :authenticate_user!, :except => [:list_popular, :list_images]
  N_INCLUDED_IMAGES = 4
  
  def create_gallery
    gal = Gallery.new params[:gallery]
    gal.user = @user
    if gal.save
      @result[:gallery_id] = gal.id
      @result[:success] = true
    else
      @result[:msg] = gal.errors 
    end
    
    return render :json => @result
  end
  
  # POST /api/edit_gallery
  # params: 
  # gallery[name]
  # gallery[description]
  def update_gallery
    # find gallery
    gallery = Gallery.find_by_id(params[:gallery][:id])
    if gallery.nil?
      @result[:msg] = "Could not find Gallery"
      return render :json => @result
    end
    # make sure the gallery is user's
    if gallery.user != @user
      @result[:msg] = "This gallery is not belong to you"
      return render :json => @result
    end
    # update gallery
    if gallery.update_attributes(params[:gallery])
      @result[:success] = true
      @result[:data] = {:gallery => gallery.serializable_hash(:only => [:id, :name, :description])}
    end
    
    render :json => @result
  end
  
  # DELETE /api/delete_gallery
  # params: id
  def delete_gallery
    # find gallery
    gallery = Gallery.find_by_id(params[:id])
    if gallery.nil?
      @result[:msg] = "Could not find Gallery"
      return render :json => @result
    end
    # make sure the gallery is user's
    if gallery.user != @user
       @result[:msg] = "This gallery is not belong to you"
        return render :json => @result
    end
    # delete gallery
    gallery.destroy
    @result[:success] = true
    
    render :json => @result
  end
  
  # GET /api/list_galleries
  # params: 
  #   page_id
  #   page_size
  #   sort_field
  #   sort_direction
  def list_galleries
    galleries = @user.galleries.select([:id, :name, :description]).load_galleries(@filtered_params)
    galleries.map! do |gallery|
      if gallery.images.length > N_INCLUDED_IMAGES
        gallery.images = gallery.images.select([:id, :name, :description, :data_file_name])
        gallery.images = gallery.images[0..(N_INCLUDED_IMAGES - 1)]
      end
    end
    
    @result[:data] = galleries
    @result[:total]  = galleries.total_entries
    @result[:success] = true
    render :json => @result
  end
  
  # GET /api/list_popular
  #   parmas: 
  #   page_id
  #   page_size
  #   sort_field
  #   sort_direction
  def list_popular
    galleries = Gallery.select([:id, :name, :description]).load_galleries(@filtered_params)
    @result[:data] = galleries
    @result[:total]  = galleries.total_entries
    @result[:success] = true
    render :json => @result
  end
  
  # GET /api/list_images
  # params: 
  # gallery_id
  #   page_id
  #   page_size
  #   sort_field
  #   sort_direction
  def list_images
    gallery = Gallery.find_by_id(params[:gallery_id])
    if gallery.nil?
      @result[:msg] = "Could not find Gallery"
      return render :json => @result
    end
    # make sure the gallery is user's
    #if gallery.user != @user
       #@result[:msg] = "This gallery is not belong to you"
        #return render :json => @result
    #end
    
    @result[:total]  = gallery.images.count
    images = gallery.images.select([:id, :name, :description, :data_file_name]).load_images(@filtered_params)
    images.each do |image|
      image[:image_url] = image.data.url
      image[:image_thumb_url] = image.data.url(:thumb)
    end
    @result[:data] = images
    @result[:success] = true
    render :json => @result
  end
end
