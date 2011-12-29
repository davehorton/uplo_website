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
  def create_gallery
    result = {:success => true}
    
    if !user_signed_in?
      result[:success] = false
      result[:msg] = "You must login first."
      return render :json => result
    end
    
    info = params[:gallery]
    gal = Gallery.new info
    gal.user = current_user
    if gal.save
      result[:gallery_id] = gal.id
    else
      result[:msg] = gal.errors 
      result[:success] = false
    end
    
    return render :json => result
  end
  
  # GET /api/list_galleries
  def list_galleries 
    result = {:success => false}
    
    if !user_signed_in?
      result[:msg] = "no user logined"
      return render :json => result
    end
    
    user = current_user
    result[:data] = user.galleries.select [:id, :name, :description]
    result[:success] = true
    render :json => result
  end
end
