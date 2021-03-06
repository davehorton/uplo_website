class ProfilesController < ApplicationController
  self.per_page = 12
  skip_before_filter :authenticate_user!, :unless => :viewing_own_profile?
  around_filter :apply_user_scope
  before_filter :find_user

  respond_to :json

  def show
    if @user == current_user
      @galleries = @user.galleries.with_images.paginate_and_sort(filtered_params)
      @images = @user.images.unflagged.with_gallery.paginate_and_sort(filtered_params)
    else
      @galleries = @user.galleries.public_access.paginate_and_sort(filtered_params)
      @images = @user.images.public_access.paginate_and_sort(filtered_params)
    end

    @liked_images = @user.liked_images.paginate_and_sort(filtered_params)
    @followers = @user.followers.paginate_and_sort(filtered_params)
    @followed_users = @user.followed_users.paginate_and_sort(filtered_params)
  end

  def photos
    if @user == current_user
      @images = @user.images.unflagged.with_gallery.paginate_and_sort(filtered_params)
    else
      @images = @user.images.popular_with_pagination(filtered_params)
    end

    html = render_to_string :partial => 'photos'
    counter = @images.count
    respond_with(html: html, counter: counter)
  end

  def get_photos
    if request.xhr?
      if @user == current_user
        images = @user.images.unflagged.with_gallery.paginate_and_sort(filtered_params)
      else
        images = @user.images.popular_with_pagination(filtered_params)
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

  def likes
    @images = @user.liked_images.with_gallery.paginate_and_sort(filtered_params)
    html = render_to_string :partial => 'likes'
    counter = @images.count
    respond_with(html: html, counter: counter)
  end

  def get_likes
    if request.xhr?
      images = @user.liked_images.with_gallery.paginate_and_sort(filtered_params)

      if @user == current_user
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

  def galleries
    if @user == current_user
      @galleries = @user.galleries.with_images.paginate_and_sort(filtered_params)
    else
      @galleries = @user.galleries.public_access.with_images.paginate_and_sort(filtered_params)
    end
    html = render_to_string :partial => 'galleries'
    counter = @galleries.count
    respond_with(html: html, counter: counter)
  end

  def get_galleries
    if request.xhr?
      if @user == current_user
        galleries = @user.galleries.with_images.paginate_and_sort(filtered_params)
      else
        galleries = @user.galleries.public_access.with_images.paginate_and_sort(filtered_params)
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

  def followers
    @followers = @user.followers.paginate_and_sort(filtered_params)
    html = render_to_string :partial => 'followers'
    counter = @followers.count
    respond_with(html: html, counter: counter)
  end

  def get_followers
    if request.xhr?
      followers = @user.followers.paginate_and_sort(filtered_params)
      template = render_to_string :partial => 'users/followers_template',
                    :locals => { :users => followers, :users_per_line => 2, :type => 'follower' }
      pagination = render_to_string :partial => 'hidden_pagination',
                    :locals => { :data_source => followers,
                                :params => { :controller => "profiles",
                                              :action => 'get_followers' } }
      render :json => { :items => template, :pagination => pagination }
    end
  end

  def followed_users
    @followed_users = @user.followed_users.paginate_and_sort(filtered_params)
    html = render_to_string :partial => 'followed_users'
    counter = @followed_users.count
    respond_with(html: html, counter: counter)
  end

  def get_followed_users
    if request.xhr?
      followed_users = @user.followed_users.paginate_and_sort(filtered_params)
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

    def viewing_own_profile?
      action_name == 'show' && !current_user && params[:user_id].nil?
    end

    def find_user
      @user = User.find(params[:user_id] || current_user.try(:id))
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "Profile not found"
      redirect_to root_path and return
    end
end
