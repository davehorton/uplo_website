class Api::SearchController < Api::BaseController
  # GET /api/search
  # params:
  #   query: search key
  #   search_type: take value in [nil, "users", "galleries", "images"]
  #   page_id
  #   page_size
  #   sort_field
  #   sort_direction
  def search
    result = { :success => false }
    if params[:search_type].downcase == Image::SEARCH_TYPE
      list = Image.search_scope(params[:query]).
                public_or_owner(current_user).
                paginate_and_sort(filtered_params)
      result = { :total => list.total_entries, :data => list, :success => true }
    elsif params[:search_type].downcase == User::SEARCH_TYPE
      list = User.search_scope(params[:query]).paginate_and_sort(filtered_params)
      result = { :total => list.total_entries, :data => list, :success => true }
    else
      result[:msg] = "'#{ params[:search_type] }' is not a search type!"
    end

    render :json => result
  end
end
