class Admin::MembersController < Admin::AdminController
  def index
    # TODO: test GUI only
    @sort_field = params[:sort_field] || "signup_date"
    @users = User.load_users(filtered_params.merge(:sort_field => @sort_field))
  end
  
  protected
  
  def default_page_size
    return 24
  end
  
  def select_tab
    @current_tab = "#admin_menu li:contains(Member Profiles)"
  end
end
