class ProfilesController < ApplicationController
  before_filter :authenticate_user!
  layout 'main'

  def show
    @user = current_user
    @images = Image.load_images(@filtered_params)
    @followers = User.all
  end

  def show_photos
    if request.xhr?
      @user = current_user
      @images = Image.load_images(@filtered_params)
      render :partial => 'photos'
    end
  end

  def get_photos
    if request.xhr?
      images = Image.load_images(@filtered_params)
      template = render_to_string :partial => 'shared/photos_template',
                    :locals => { :images => images,
                                :photos_per_line => 4, :photo_size => 'thumb' }
      pagination = render_to_string :partial => 'shared/hidden_pagination',
                    :locals => { :data_source => images,
                                :params => { :controller => "profiles",
                                              :action => 'get_photos' } }
      render :json => { :photos => template, :pagination => pagination }
    end
  end

  def show_galleries
    if request.xhr?
      @user = current_user
      @galleries = Gallery.load_galleries(@filtered_params)
      render :partial => 'galleries'
    end
  end

  def get_galleries
    if request.xhr?
      galleries = Gallery.load_galleries(@filtered_params)
      template = render_to_string :partial => 'shared/galleries_template',
                    :locals => { :galleries => galleries, :galleries_per_line => 4 }
      pagination = render_to_string :partial => 'shared/hidden_pagination',
                    :locals => { :data_source => galleries,
                                :params => { :controller => "profiles",
                                              :action => 'get_galleries' } }
      render :json => { :galleries => template, :pagination => pagination }
    end
  end

  protected
  def default_page_size
    actions = ['show']
    if actions.index(params[:action])
      size = 12
    else
      size = 4
    end
    return size
  end
end
