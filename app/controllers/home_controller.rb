class HomeController < ApplicationController
  def index
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
    return 30
  end
end
