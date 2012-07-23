class Admin::MembersController < Admin::AdminController
  def index
    @sort_field = params[:sort_field] || "signup_date"
    @sort_direction = params[:sort_direction] || "asc"
    @users = User.load_users(filtered_params.merge(
      :sort_field => @sort_field, 
      :sort_direction => @sort_direction
    ))
  end
  
  def search
    search_params = {:query => URI.unescape(params[:query]), :filtered_params => filtered_params}
    @users = User.do_search(search_params)
    render 'admin/members/index'
  end
  
  protected
  
    def default_page_size
      return 24
    end
    
    def set_current_tab
      @current_tab = "member_profiles"
    end
end