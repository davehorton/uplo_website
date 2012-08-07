class HomeController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]
  layout 'main'

  def index
    session[:back_url] = url_for(:controller => 'home', :action => "browse") if session[:back_url].nil?
    if user_signed_in?
      @images = Image.un_flagged.load_popular_images(@filtered_params)
      redirect_to :action => :spotlight
    else
      @images = Image.get_all_images_with_current_user(@filtered_params)
    end
  end

  def browse
    @images = Image.get_browse_images(@filtered_params)
  end

  def spotlight
    @images = Image.get_spotlight_images(@filtered_params)
    @recent_images = Image.get_browse_images(@filtered_params)
  end

  def friends_feed
    @images = current_user.friends_images.un_flagged.load_popular_images(@filtered_params)
  end

  def intro
  end

  def search
    process_search_params
    if params[:filtered_by] == Image::SEARCH_TYPE
      @filtered_params[:sort_criteria] = Image::SORT_CRITERIA[params[:sort_by]]
      @data = Image.un_flagged.public_images.do_search({
        :query => URI.unescape(params[:query]),
        :filtered_params => @filtered_params })
    else #filtered by user
      @filtered_params[:sort_criteria] = User::SORT_CRITERIA[params[:sort_by]]
      @data = User.active_users.do_search({
        :query => URI.unescape(params[:query]),
        :filtered_params => @filtered_params })
    end
  end

  protected
    def default_page_size
      size = 30
      if params[:action] == "browse" || params[:action] == 'friends_feed' || params[:action] == 'index' || params[:action] == "search"
        size = 24
      elsif params[:action] == "spotlight"
        size = 12
      end
      return size
    end

    def process_search_params
      params[:filtered_by] = Image::SEARCH_TYPE if params[:filtered_by].blank?
      if params[:filtered_by] == Image::SEARCH_TYPE
        params[:sort_by] = Image::SORT_OPTIONS[:recent]
      else #filtered by user
        params[:sort_by] = User::SORT_OPTIONS[:name]
      end
    end
end
