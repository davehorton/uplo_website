class Admin::MembersController < Admin::AdminController
  self.per_page = 24

  def index
    @sort_field = params[:sort_field] || "signup_date"
    @sort_direction = params[:sort_direction] || "asc"
    @users = User.confirmed.includes(:public_images).paginate_and_sort(filtered_params.merge(
      :sort_field => @sort_field,
      :sort_direction => @sort_direction
    ))
  end

  def search
    @users  = User.search_scope(params[:admin_query]).paginate_and_sort(filtered_params)
    render 'admin/members/index'
  end

  def export
    render text: User.confirmed.to_csv
  end

  protected

    def set_current_tab
      @current_tab = "member_profiles"
    end
end
