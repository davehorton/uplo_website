class ProfilesController < ApplicationController
  before_filter :authenticate_user!, :find_user
  layout 'main'

  def show
    @images = @user.images.load_images(@filtered_params)
    @galleries = @user.galleries.load_galleries(@filtered_params)
    @followers = @user.followers.load_users(@filtered_params)
    @followed_users = @user.followed_users.load_users(@filtered_params)
  end

  def show_photos
    if request.xhr?
      @images = @user.images.load_images(@filtered_params)
      render :partial => 'photos'
    end
  end

  def get_photos
    if request.xhr?
      images = @user.images.load_images(@filtered_params)
      template = render_to_string :partial => 'shared/photos_template',
                    :locals => { :images => images,
                                :photos_per_line => 4, :photo_size => 'thumb' }
      pagination = render_to_string :partial => 'shared/hidden_pagination',
                    :locals => { :data_source => images,
                                :params => { :controller => "profiles",
                                              :action => 'get_photos' } }
      render :json => { :items => template, :pagination => pagination }
    end
  end

  def show_galleries
    if request.xhr?
      @galleries = @user.galleries.load_galleries(@filtered_params)
      render :partial => 'galleries'
    end
  end

  def get_galleries
    if request.xhr?
      galleries = @user.galleries.load_galleries(@filtered_params)
      template = render_to_string :partial => 'shared/galleries_template',
                    :locals => { :galleries => galleries, :galleries_per_line => 4 }
      pagination = render_to_string :partial => 'shared/hidden_pagination',
                    :locals => { :data_source => galleries,
                                :params => { :controller => "profiles",
                                              :action => 'get_galleries' } }
      render :json => { :items => template, :pagination => pagination }
    end
  end

  def show_followers
    if request.xhr?
      @followers = @user.followers.load_users(@filtered_params)
      render :partial => 'followers'
    end
  end

  def get_followers
    if request.xhr?
      followers = @user.followers.load_users(@filtered_params)
      template = render_to_string :partial => 'users/followers_template',
                    :locals => { :users => followers, :users_per_line => 2 }
      pagination = render_to_string :partial => 'shared/hidden_pagination',
                    :locals => { :data_source => followers,
                                :params => { :controller => "profiles",
                                              :action => 'get_followers' } }
      render :json => { :items => template, :pagination => pagination }
    end
  end

  def show_followed_users
    if request.xhr?
      @followed_users = @user.followed_users.load_users(@filtered_params)
      render :partial => 'followed_users'
    end
  end

  def get_followed_users
    if request.xhr?
      followed_users = @user.followed_users.load_users(@filtered_params)
      template = render_to_string :partial => 'users/followers_template',
                    :locals => { :users => followed_users, :users_per_line => 2 }
      pagination = render_to_string :partial => 'shared/hidden_pagination',
                    :locals => { :data_source => followed_users,
                                :params => { :controller => "profiles",
                                              :action => 'get_followed_users' } }
      render :json => { :items => template, :pagination => pagination }
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

  def find_user
    if params[:user_id].nil?
      @user = current_user
    else
      @user = User.find params[:user_id]
    end
  end
end
