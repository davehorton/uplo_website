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
  before_filter :require_login!, :except => [:list_popular, :list_images]

  def create_gallery
    if params[:gallery]['permission']=='0'
      params[:gallery]['permission'] = 'protected'
    else
      params[:gallery]['permission'] = 'public'
    end
    gal = Gallery.new(params[:gallery])
    gal.user = @user
    if gal.save
      @result[:gallery_id] = gal.id
      @result[:public_link] = gal.public_link
      @result[:success] = true
    else
      @result[:msg] = gal.errors.full_messages.to_sentence
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
    if gallery.user_id != @user.id
      @result[:msg] = "This gallery is not belong to you"
      return render :json => @result
    end
    # update gallery
    if params[:gallery]['permission']=='0'
      params[:gallery]['permission'] = 'protected'
    else
      params[:gallery]['permission'] = 'public'
    end
    if gallery.update_attributes(params[:gallery])
      @result[:success] = true
      @result[:gallery] = gallery.serializable_hash(gallery.default_serializable_options)
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
    if gallery.user_id != @user.id
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
  #   user_id: if null, list galleries of current user
  def list_galleries
    if params.has_key?("user_id") && params[:user_id]!=""
      author = User.find_by_id params[:user_id].to_i
      if author.nil?
        @result[:msg] = "User does not exist."
        @result[:success] = false
        render :json => @result and return
      end
    else
      author = @user
    end

    galleries = author.galleries.load_galleries(@filtered_params)
    @result[:total] = galleries.total_entries
    @result[:data] = galleries_to_json(galleries)
    @result[:success] = true
    render :json => @result
  end

  # GET /api/list_popular
  #   parmas:
  #   page_id
  #   page_size
  #   sort_field
  #   sort_direction
  #   user_id
  def list_popular
    if params[:user_id].nil?
      galleries = Gallery.load_popular_galleries(@filtered_params)
    else
      user = User.find_by_id params[:user_id]
      galleries = user.public_galleries.load_galleries(@filtered_params)
    end
    @result[:total] = galleries.total_entries
    @result[:data] = galleries_to_json(galleries)
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
    #if gallery.user_id != @user.id
       #@result[:msg] = "This gallery is not belong to you"
        #return render :json => @result
    #end

    @result[:total]  = gallery.images.count
    images = gallery.images.load_images(@filtered_params)
    images.each do |image|
      image[:image_url] = image.data.url
      image[:image_thumb_url] = image.data.url(:thumb)
    end
    @result[:data] = images
    @result[:success] = true
    render :json => @result
  end

  protected

  def galleries_to_json(galleries)
    json_array = []

    galleries.each do |gallery|
      data = {}
      data[:gallery] = gallery.serializable_hash({
        :except => gallery.except_attributes,
        :methods => gallery.exposed_methods,
      })

      if data[:gallery][:cover_image]
        data[:gallery][:cover_image] = data[:gallery][:cover_image].serializable_hash(Image.default_serializable_options)
        data[:gallery][:updated_at] = gallery.updated_at.strftime('%m/%d/%y')
      else
        data[:gallery][:cover_image] = {:image_thumb_url => "http://#{DOMAIN}/assets/gallery-thumb-180.jpg"}
      end

      json_array << data
    end

    return json_array
  end
end
