class HomeController < ApplicationController
  before_filter :authenticate_user!, :only => [:browse]

  def index
    session[:back_url] = url_for(:controller => 'home', :action => "browse") if session[:back_url].nil?
    @images = Image.load_popular_images(@filtered_params)
  end

  def browse
    @images = Image.load_popular_images(@filtered_params)
    render :template => 'home/new_browse', :layout => "main"
  end

  def search
    @no_async_image_tag = true
    limit_filtered_params = @filtered_params
    limit_filtered_params[:page_size] = 3
    @users = User.do_search({:query => URI.unescape(params[:query]), :filtered_params => limit_filtered_params})
    @galleries = Gallery.do_search({:query => URI.unescape(params[:query]), :filtered_params => limit_filtered_params})
    @images = Image.do_search({:query => URI.unescape(params[:query]), :filtered_params => @filtered_params})
  end

  protected

  def set_current_tab
    tab = "popular"
    browse_actions = ["browse", "search"]
    unless browse_actions.index(params[:action]).nil?
      tab = "browse"
    end
    @current_tab = tab
  end

  def default_page_size
    size = 30
    if params[:action] == "browse"
      size = 24
    elsif params[:action] == "search" || params[:action] == "spotlight"
      size = 12
    end
    return size
  end
end
