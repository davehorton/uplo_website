class ProfilesController < ApplicationController
  layout 'main'
  def show
    @user = current_user
    @images = Image.load_images(@filtered_params)
    @followers = User.all
  end

  def list_photos
    if request.xhr?
      @user = current_user
      @images = Image.load_images(@filtered_params)
      render :partial => 'photos'
    end
  end

  def list_galleries
    if request.xhr?
      render :partial => 'photos'
    end
  end

  protected
  def default_page_size
    actions = ['show']
    if actions.index(params[:action])
      size = 12
    else
      size = 24
    end
    return size
  end
end
