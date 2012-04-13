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
      free_allocation = [0, (FileSizeConverter.convert current_user.free_allocation, FileSizeConverter::UNITS[:byte], mb_unit)].max
      @result[:msg] = "UPLOAD FAILED! This image is #{mb_img_size} #{mb_unit.upcase}. You have only #{free_allocation} #{mb_unit.upcase} / #{User::ALLOCATION_STRING} free"
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
    @result[:data] = process_public_images(images)
    @result[:success] = true
    render :json => @result
  end

  def like
    result = {:success => false}
    image = Image.find_by_id(params[:id])
    if image.nil?
      result[:msg] = "This image does not exist anymore!"
      return render :json => result
    end
    if user_signed_in?
      result = SharedMethods::Converter.Boolean(params[:dislike]) ? image.disliked_by_user(current_user.id) : image.liked_by_user(current_user.id)
    else
      result[:msg] = "You have to sign in first"
    end
    render :json => result
  end

  def total_sales
    image = Image.find_by_id params[:image_id]
    user = current_user

    if image.nil?
      result = {
        :success => false,
        :msg => "This image does not exist anymore!"
      }
    elsif !Gallery.exists?({:id => image.gallery_id, :user_id => user.id})
      result = {
        :success => false,
        :msg => "This image is not yours!"
      }
    else
      result = {
        :success => true,
        :image => image.serializable_hash(image.default_serializable_options),
        :total => image.total_sales,
        :sale_chart => url_for(:action => :sale_chart, :image_id => image.id, :only_path => false),
        :saled_quantity => image.saled_quantity,
        :purchased_info => image.get_purchased_info
      }
    end

    render :json => result
  end

  def get_purchasers
    image = Image.find_by_id params[:image_id]
    user = current_user

    if image.nil?
      result = {
        :success => false,
        :msg => "This image does not exist anymore!"
      }
    elsif !Gallery.exists?({:id => image.gallery_id, :user_id => user.id})
      result = {
        :success => false,
        :msg => "This image is not yours!"
      }
    else
      purchased_info = image.get_purchased_info(@filtered_params)
      result = {
        :success => true,
        :total => purchased_info[:total],
        :data => purchased_info[:data]
      }
    end

    render :json => result
  end

  def sale_chart
    image = Image.find_by_id params[:image_id]
    user = current_user

    if image.nil?
      @text = "This image does not exist anymore!"
      return render :template => "images/sale_chart.html.haml", :layout => "blank"
    elsif !Gallery.exists?({:id => image.gallery_id, :user_id => user.id})
      @text = "This image is not yours!"
      return render :template => "images/sale_chart.html.haml", :layout => "blank"
    else
      @monthly_sales = image.get_monthly_sales_over_year(Time.now, {:report_by => Image::SALE_REPORT_TYPE[:quantity]})
      return render :file => "shared/sale_chart.html.erb", :layout => false
    end
  end

  protected
  def process_public_images(images)
    result = []
    images.map { |img|
      info = img.serializable_hash(img.default_serializable_options)
      info[:liked] = current_user.nil? ? false : img.is_liked?(current_user.id)
      result << {:image => info}
    }
    return result
  end
end
