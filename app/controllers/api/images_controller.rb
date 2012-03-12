=begin
create_table "images", :force => true do |t|
  t.string   "name",              :null => false
  t.text     "description"
  t.integer  "gallery_id",        :null => false
  t.datetime "created_at"
  t.datetime "updated_at"
  t.string   "data_file_name"
  t.string   "data_content_type"
  t.integer  "data_file_size"
  t.datetime "data_updated_at"
end
=end

class Api::ImagesController < Api::BaseController
  before_filter :require_login!
  include ::SharedMethods::Converter

  # POST /api/upload_image
  # params: image[data], gallery_id, image[name], image[description]
  def upload_image
    @result[:success] = false

    if !user_signed_in?
      @result[:msg] = "You must login first."
      return render :json => @result
    end
    img_size = File.new(params[:image][:data].tempfile).size
    if img_size > current_user.free_allocation
      mb_unit = FileSizeConverter::UNITS[:megabyte]
      mb_img_size = FileSizeConverter.convert img_size, FileSizeConverter::UNITS[:byte], mb_unit
      free_allocation = FileSizeConverter.convert current_user.free_allocation, FileSizeConverter::UNITS[:byte], mb_unit
      @result[:msg] = "UPLOAD FAIL! This image is #{mb_img_size} #{mb_unit.upcase}. You have only #{free_allocation} #{mb_unit.upcase} / #{User::ALLOCATION_STRING} free"
      # raise exception
      render :json => @result.to_json and return
    end

    user = current_user
    gallery = user.galleries.find_by_id(params[:gallery_id])
    if gallery.nil?
      @result[:msg] = "Could not find Gallery"
      @result[:success] = false
      return render :json => @result
    end
    img_info = params[:image]
    effect_id = nil
    if img_info.has_key?(:effect_id) and !img_info[:effect_id].nil? and img_info[:effect_id]!=""
      effect_id = img_info[:effect_id] if img_info[:effect_id].to_i > 0
      img_info.delete :effect_id
    end

    image = gallery.images.create(img_info)
    if !image.save
      @result[:msg] = image.errors
      @result[:success] = false
    elsif !effect_id.nil?
      file_path = "#{Rails.root}/tmp/#{image.name}"
      FilterEffect::Effect.send("e#{effect_id}", image.url, file_path)
      image.data = File.open(file_path)
      if image.save
        @result[:image] = image.serializable_hash(image.default_serializable_options)
        @result[:success] = true
      else
        @result[:msg] = image.errors
        @result[:success] = false
      end
    else
      @result[:image] = image.serializable_hash(image.default_serializable_options)
        @result[:success] = true
    end

    render :json => @result
  end

  # POST /api/update_image
  # params: image[id], image[name], image[description]
  def update_image
    @result[:success] = false

    if !user_signed_in?
      @result[:msg] = "You must login first."
      return render :json => @result
    end

    user = current_user
    # find image
    image = Image.find_by_id(params[:image][:id])
    if image.nil?
      @result[:msg] = "Could not find Image"
      return render :json => @result
    end
    # make sure the image is user's
    if image.gallery.user_id != user.id
      @result[:msg] = "This image is not belong to you"
      return render :json => @result
    end
    # update image
    if image.update_attributes(params[:image])
      @result[:success] = true
      @result[:image] = image.serializable_hash(image.default_serializable_options)
    end

    render :json => @result
  end

  # DELETE /api/delete_image
  # params:id
  def delete_image
    @result[:success] = false
    if !user_signed_in?
      @result[:msg] = "You must login first."
      return render :json => @result
    end
    # TODO: uncomment this
    user = current_user
    #user = User.find_by_username :admin

    # find image
    image = Image.find_by_id(params[:id])
    if image.nil?
      @result[:msg] = "Could not find Image"
      return render :json => @result
    end
    # make sure the image is user's
    if image.gallery.user_id != user.id
      @result[:msg] = "This image is not belong to you"
      return render :json => @result
    end

    # Delete!
    image.destroy
    @result[:success] = true
    render :json => @result
  end

  def popular_images
    images = Image.load_popular_images(@filtered_params)
    @result[:total] = images.total_entries
    @result[:data] = images
    @result[:success] = true
    render :json => @result
  end

  def like
    image = Image.find_by_id(params[:id])
    if image.nil?
      @result[:success] = false
      @result[:msg] = "Could not find Image"
      return render :json => @result
    end

    image.likes += 1
    if user_signed_in?
      img_like = ImageLikes.new({:image_id => image.id, :user_id => current_user.id})
      image.image_likes << img_like
    end
    if image.save
      @result[:success] = true
      @result[:likes] = image.likes
    else
      @result[:success] = false
      @result[:msg] = "Action failure! Please try your like later."
    end
    return render :json => @result
  end
end
