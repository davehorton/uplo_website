class HomeController < ApplicationController
  self.page_size = 30

  skip_before_filter :authenticate_user!, only: [:index, :terms, :privacy]

  IMAGE_SORT_VIEW = {
    Image::SORT_OPTIONS[:view] => 'Most Views',
    Image::SORT_OPTIONS[:recent] => 'Recent Uploads',
    Image::SORT_OPTIONS[:spotlight] => 'Spotlight Images'
  }

  USER_SORT_VIEW = {
    User::SORT_OPTIONS[:name] => 'Best Match',
    User::SORT_OPTIONS[:date_joined] => 'Date Joined'
  }

  def index
    session[:back_url] = url_for(:controller => 'home', :action => "browse") if session[:back_url].nil?
    @images = Image.search_scope(current_user).spotlight.paginate_and_sort(filtered_params)
    if user_signed_in?
      @current_views = 'recent images'
      filtered_params[:sort_direction] = 'DESC'
      filtered_params[:sort_field] = "updated_at"
      @recent_images = Image.visible_everyone.paginate_and_sort(filtered_params)
      render :template => 'home/spotlight'
    else
      @devise_message = session.delete(:devise_message)
    end
  end

  def browse
    @current_views = IMAGE_SORT_VIEW[Image::SORT_OPTIONS[:recent]]
    filtered_params[:sort_direction] = 'DESC'
    filtered_params[:sort_field] = "created_at"
    @data = Image.visible_everyone.paginate_and_sort(filtered_params)
  end

  def spotlight
    @current_views = IMAGE_SORT_VIEW[Image::SORT_OPTIONS[:spotlight]]
    filtered_params[:sort_direction] = 'DESC'
    filtered_params[:sort_field] = "created_at"
    @data = Image.search_scope(current_user).spotlight.paginate_and_sort(filtered_params)
    render :template => 'home/browse'
  end

  def terms
  end

  def payment
  end

  def friends_feed
    @images = current_user.friends_images.popular_with_pagination(filtered_params)
  end

  def intro
  end

  def search
    process_search_params
    if params[:filtered_by] == Image::SEARCH_TYPE
      @current_views = IMAGE_SORT_VIEW[params[:sort_by]]
      filtered_params[:sort_direction] = 'DESC'
      case params[:sort_by]
      when "recent"
        filtered_params[:sort_field] = "created_at"
      when "views"
        filtered_params[:sort_field] = "pageview"
      when "spotlight"
        filtered_params[:sort_field] = "promote"
      end

      @data = Image.search_scope(params[:query]).
                public_or_owner(current_user).
                paginate_and_sort(filtered_params)

    else #filtered by user
      @current_views = USER_SORT_VIEW[params[:sort_by]]
      filtered_params[:sort_criteria] = User::SORT_CRITERIA[params[:sort_by]]
      @data = User.search_scope(params[:query]).paginate_and_sort(filtered_params)
    end
    render :template => 'home/browse'
  end

  protected

    def process_search_params
      params[:filtered_by] = Image::SEARCH_TYPE if params[:filtered_by].blank?
      if params[:filtered_by] == Image::SEARCH_TYPE
        params[:sort_by] = Image::SORT_OPTIONS[:recent] if params[:sort_by].blank? || !Image::SORT_OPTIONS.has_value?(params[:sort_by])
      else #filtered by user
        params[:sort_by] = User::SORT_OPTIONS[:name] if params[:sort_by].blank?|| !User::SORT_OPTIONS.has_value?(params[:sort_by])
      end
    end
end
