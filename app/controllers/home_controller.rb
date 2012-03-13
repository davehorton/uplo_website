class HomeController < ApplicationController
  before_filter :authenticate_user!, :only => [:browse]

  def index
    session[:back_url] = url_for(:controller => 'home', :action => "browse") if session[:back_url].nil?
    @images = Image.load_popular_images(@filtered_params)
  end

  def browse
    @images = Image.load_popular_images(@filtered_params)
  end

  def search
    @no_async_image_tag = true
    @users = User.search params[:query], :star => true, :page => params[:page_id], :per_page => 3
    @galleries = Gallery.search params[:query], :star => true, :page => params[:page_id], :per_page => 3
    @images = Image.search params[:query], :star => true, :page => params[:page_id], :per_page => default_page_size
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
      size = 12
    elsif params[:action] == "search"
      size = 12
    end
    return size
  end
end
