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
  before_filter :authenticate_user!
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
  
  # POST /api/edit_gallery
  # params: 
  # gallery[name]
  # gallery[description]
  def update_gallery
    result = {:success => false}
    user = current_user
    # find gallery
    gallery = Gallery.find_by_id(params[:gallery][:id])
    if gallery.nil?
      result[:msg] = "Could not find Gallery"
      return render :json => result
    end
    # make sure the gallery is user's
    if gallery.user != user
       result[:msg] = "This gallery is not belong to you"
        return render :json => result
    end
    # update gallery
    if gallery.update_attributes(params[:gallery])
      result[:success] = true
      result[:data] = {:gallery => gallery.serializable_hash(:only => [:id, :name, :description])}
    end
    
    render :json => result
  end
  
  # DELETE /api/delete_gallery
  # params: id
  def delete_gallery
    result = {:success => false}
    user = current_user
    # find gallery
    gallery = Gallery.find_by_id(params[:id])
    if gallery.nil?
      result[:msg] = "Could not find Gallery"
      return render :json => result
    end
    # make sure the gallery is user's
    if gallery.user != user
       result[:msg] = "This gallery is not belong to you"
        return render :json => result
    end
    # delete gallery
    gallery.destroy
    result[:success] = true
    
    render :json => result
  end
  
  # GET /api/list_galleries
  def list_galleries
    result = {:success => false}
    
    if !user_signed_in?
      result[:msg] = "You must login first."
      return render :json => result
    end

    user = current_user
    pagination = {:total => user.galleries.count}
    result[:data] = user.galleries.select([:id, :name, :description])
            .paginate(:page => params[:page], :per_page => params[:limit])
            .all(:order => params[:orderby].nil? ? 'id DESC' : params[:orderby] + ' DESC')
    result[:success] = true
    result[:pagination] = pagination
    render :json => result
  end
end
