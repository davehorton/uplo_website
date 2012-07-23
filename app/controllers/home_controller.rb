class HomeController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]

  def index
    session[:back_url] = url_for(:controller => 'home', :action => "browse") if session[:back_url].nil?
    @images = Image.un_flagged.load_popular_images(@filtered_params)
    if user_signed_in?
      redirect_to :action => :spotlight
    end
  end

  def browse
    @images = Image.get_all_images_with_current_user(@filtered_params, current_user)
    render :template => 'home/new_browse', :layout => "main"
  end

  def spotlight
    @images = Image.get_all_images_with_current_user(@filtered_params, current_user)
    render :layout => "main"
  end

  def friends_feed
    @images = current_user.friends_images.un_flagged.load_popular_images(@filtered_params)
    render :layout => 'main'
  end

  def intro
    render :layout => "main"
  end

  def popular
    session[:back_url] = url_for(:controller => 'home', :action => "browse") if session[:back_url].nil?
    @images = Image.get_all_images_with_current_user(@filtered_params, current_user)
    render :layout => "main"
  end

  def search
    @no_async_image_tag = true
    limit_filtered_params = @filtered_params
    limit_filtered_params[:page_size] = 3
    @users = User.do_search({:query => URI.unescape(params[:query]), :filtered_params => limit_filtered_params})
    @galleries = Gallery.do_search({:query => URI.unescape(params[:query]), :filtered_params => limit_filtered_params})
    @images = Image.un_flagged.do_search({:query => URI.unescape(params[:query]), :filtered_params => @filtered_params})
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
    if params[:action] == "browse" || params[:action] == 'friends_feed'
      size = 24
    elsif params[:action] == "search" || params[:action] == "spotlight"
      size = 12
    end
    return size
  end
end
