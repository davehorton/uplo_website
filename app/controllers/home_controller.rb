class HomeController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]
  layout 'main'

  def index
    session[:back_url] = url_for(:controller => 'home', :action => "browse") if session[:back_url].nil?
    if user_signed_in?
      @images = Image.un_flagged.load_popular_images(@filtered_params)
      redirect_to :action => :spotlight
    else
      @images = Image.get_all_images_with_current_user(@filtered_params)
    end
  end

  def browse
    @images = Image.get_all_images_with_current_user(@filtered_params, current_user)
  end

  def spotlight
    @images = Image.get_all_images_with_current_user(@filtered_params, current_user)
  end

  def friends_feed
    @images = current_user.friends_images.un_flagged.load_popular_images(@filtered_params)
  end

  def intro
  end

  def search
    @no_async_image_tag = true
    limit_filtered_params = @filtered_params
    limit_filtered_params[:page_size] = 3
    @users = User.do_search({:query => URI.unescape(params[:query]), :filtered_params => limit_filtered_params})
    @galleries = Gallery.do_search({:query => URI.unescape(params[:query]), :filtered_params => limit_filtered_params})
    @images = Image.un_flagged.do_search({:query => URI.unescape(params[:query]), :filtered_params => @filtered_params})
    render :layout => 'application'
  end

  def filtering_search
    redirect_to '/'
  end

  protected
    def default_page_size
      size = 30
      if params[:action] == "browse" || params[:action] == 'friends_feed' || params[:action] == 'index'
        size = 24
      elsif params[:action] == "search" || params[:action] == "spotlight"
        size = 12
      end
      return size
    end
end
