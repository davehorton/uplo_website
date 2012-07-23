class Admin::MembersController < Admin::AdminController
  def index
    @sort_field = params[:sort_field] || "signup_date"
    @users = User.load_users(filtered_params.merge(:sort_field => @sort_field))
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
  
  def select_tab
    @current_tab = "member_profiles"
  end
end
