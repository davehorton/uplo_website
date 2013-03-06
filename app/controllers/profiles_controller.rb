class ProfilesController < ApplicationController
  before_filter :authenticate_user!, :find_user
  layout 'main'

  def show
    if @user.blank?
      # Redirect to the current user's profile and show the warning message.
      flash[:warning] = I18n.t("user.user_was_banned_or_removed")
      return redirect_to(:action => 'show')
    end

    if @user.id == current_user.id
      @galleries = @user.galleries.load_galleries(@filtered_params)
      @images = @user.images.unflagged.load_images(@filtered_params)
    else
      @galleries = @user.galleries.load_popular_galleries(@filtered_params)
      @images = @user.images.unflagged.load_popular_images(@filtered_params)
    end

    @liked_images = @user.liked_images.visible_everyone.load_images(@filtered_params)
    @followers = @user.followers.load_users(@filtered_params)
    @followed_users = @user.followed_users.load_users(@filtered_params)
  end

  def show_photos
    if request.xhr?
      if @user.id == current_user.id
        @images = @user.images.unflagged.load_images(@filtered_params)
      else
        @images = @user.images.unflagged.load_popular_images(@filtered_params)
      end

      html = render_to_string :partial => 'photos'
      counter = @images.count
      render :json => {:html => html, :counter => counter}
    end
  end

  def get_photos
    if request.xhr?
      if @user.id == current_user.id
        images = @user.images.unflagged.load_images(@filtered_params)
      else
        images = @user.images.unflagged.load_popular_images(@filtered_params)
      end
      template = render_to_string :partial => 'images/photos_template',
                    :locals => { :images => images,
                                :photos_per_line => 4, :photo_size => 'thumb' }
      pagination = render_to_string :partial => 'hidden_pagination',
                    :locals => { :data_source => images,
                                :params => { :controller => "profiles",
                                              :action => 'get_photos' } }
      render :json => { :items => template, :pagination => pagination }
    end
  end

  def show_likes
    if request.xhr?
      @images = @user.liked_images.visible_everyone.load_images(@filtered_params)
      html = render_to_string :partial => 'likes'
      counter = @images.count
      render :json => {:html => html, :counter => counter}
    end
  end

  def get_likes
    if request.xhr?
      images = @user.liked_images.visible_everyone.load_images(@filtered_params)

      if @user.id == current_user.id
        template = render_to_string :partial => 'edit_likes_template', :locals => { :images => images }
      else
        template = render_to_string :partial => 'images/photos_template', :locals => { :images => images, :photos_per_line => 4, :photo_size => 'thumb' }
      end
      pagination = render_to_string :partial => 'hidden_pagination',
        :locals => { :data_source => images,
          :params => { :controller => "profiles", :action => 'get_likes' } }
      render :json => { :items => template, :pagination => pagination }
    end
  end

  def show_galleries
    if request.xhr?
      if @user.id == current_user.id
        @galleries = @user.galleries.load_galleries(@filtered_params)
      else
        @galleries = @user.galleries.load_popular_galleries(@filtered_params)
      end
      html = render_to_string :partial => 'galleries'
      counter = @galleries.count
      render :json => {:html => html, :counter => counter}
    end
  end

  def get_galleries
    if request.xhr?
      if @user.id == current_user.id
        galleries = @user.galleries.load_galleries(@filtered_params)
      else
        galleries = @user.galleries.load_popular_galleries(@filtered_params)
      end
      template = render_to_string :partial => 'galleries_template',
                    :locals => { :galleries => galleries, :galleries_per_line => 4 }
      pagination = render_to_string :partial => 'hidden_pagination',
                    :locals => { :data_source => galleries,
                                :params => { :controller => "profiles",
                                              :action => 'get_galleries' } }
      render :json => { :items => template, :pagination => pagination }
    end
  end

  def show_followers
    if request.xhr?
      @followers = @user.followers.load_users(@filtered_params)
      html = render_to_string :partial => 'followers'
      counter = @followers.count
      render :json => {:html => html, :counter => counter}
    end
  end

  def get_followers
    if request.xhr?
      followers = @user.followers.load_users(@filtered_params)
      template = render_to_string :partial => 'users/followers_template',
                    :locals => { :users => followers, :users_per_line => 2, :type => 'follower' }
      pagination = render_to_string :partial => 'hidden_pagination',
                    :locals => { :data_source => followers,
                                :params => { :controller => "profiles",
                                              :action => 'get_followers' } }
      render :json => { :items => template, :pagination => pagination }
    end
  end

  def show_followed_users
    if request.xhr?
      @followed_users = @user.followed_users.load_users(@filtered_params)
      html = render_to_string :partial => 'followed_users'
      counter = @followed_users.count
      render :json => {:html => html, :counter => counter}
    end
  end

  def get_followed_users
    if request.xhr?
      followed_users = @user.followed_users.load_users(@filtered_params)
      template = render_to_string :partial => 'users/followers_template',
                    :locals => { :users => followed_users, :users_per_line => 2, :type => 'following' }
      pagination = render_to_string :partial => 'hidden_pagination',
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
      if current_user.is_admin?
        @user = User.find_by_id params[:user_id]
      else
        @user = User.active_users.find_by_id params[:user_id]
      end
    end
  end
end
