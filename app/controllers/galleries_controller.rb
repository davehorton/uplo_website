class GalleriesController < ApplicationController
  load_and_authorize_resource
  
  def index
    @galleries = current_user.galleries.load_galleries(@filtered_params)
  end
  
  protected
  
  def set_current_tab
    @current_tab = "galleries"
  end
end
