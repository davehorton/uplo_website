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
  
  # POST /api/upload_image
  # params: image[data], gallery_id, image[name], image[description]
  def upload_image
    result = {:success => false}
    
    if !user_signed_in?
      result[:msg] = "no user logined"
      return render :json => result
    end 
    
    user = current_user
    gallery = Gallery.find_by_id(params[:gallery_id])
    
    if gallery.nil?
      result[:msg] = "can not find Gallery"
      result[:success] = false
      return render :json => result
    end
    
    image = gallery.images.create(params[:image])
    
    unless image.save
      result[:msg] = image.errors 
      result[:success] = false
    else
      result[:data] = {:image => image.serializable_hash(:only => [:id])}
      result[:success] = true
    end
    
    render :json => result
  end
  
  # POST /api/update_image
  # params: image[id], image[name], image[description]
  def update_image
    result = {:success => false}
    if !user_signed_in?
      result[:msg] = "no user logined"
      return render :json => result
    end
    
    user = current_user
    
    # find image
    image = Image.find_by_id(params[:image][:id])
    if image.nil?
      result[:msg] = "can not find Image"
      return render :json => result
    end
    # make sure the image is user's
    if image.gallery.user != user
       result[:msg] = "this image is not belong to you"
        return render :json => result
    end
    # update image
    if image.update_attributes(params[:image])
      result[:success] = true
      result[:data] = {:image => image.serializable_hash(:only => [:id, :name, :description])}
    end
    
    render :json => result
  end
  
  # DELETE /api/delete_image
  # params:id
  def delete_image
    result = {:success => false}
    if !user_signed_in?
      result[:msg] = "no user logined"
      return render :json => result
    end
    user = current_user
    
    # find image
    image = Image.find_by_id(params[:id])
    if image.nil?
      result[:msg] = "can not find Image"
      return render :json => result
    end
    # make sure the image is user's
    if image.gallery.user != user
       result[:msg] = "this image is not belong to you"
        return render :json => result
    end
    
    # Delete!
    image.destroy
    result[:success] = true
    render :json => result
  end
  
end
