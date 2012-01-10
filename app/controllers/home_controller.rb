class HomeController < ApplicationController
  def index
    @galleries = Gallery.load_popular_galleries(@filtered_params)
  end
  
  protected
  
  def set_current_tab
    @current_tab = "popular"
  end
end
