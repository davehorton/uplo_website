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
