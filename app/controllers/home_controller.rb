class HomeController < ApplicationController
  before_filter :authenticate_user!, :only => [:browse]
  
  def index
    session[:back_url] = url_for(:controller => 'home', :action => "browse") if session[:back_url].nil?
    @images = Image.load_popular_images(@filtered_params)
  end
  
  def browse
    @images = Image.load_popular_images(@filtered_params)
  end
  
  protected
  
  def set_current_tab
    tab = "popular"
    if params[:action] == "browse"
      tab = "browse"
    end
    @current_tab = tab
  end
  
  def default_page_size
    size = 30
    if params[:action] == "browse"
      size = 12
    end
    return size
  end
end
