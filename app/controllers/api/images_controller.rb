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
  
  def upload_image
    result = {:success => false}
    
    if !user_signed_in?
      result[:msg] = "no user logined"
      return render :json => result
    end 
    
    user = current_user
    gallery = Gallery.find(params[:gallery_id])
    
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
      result[:data] = [:image => {:id => image.id}]
      result[:success] = true
    end
    
    render :json => result
  end
end
