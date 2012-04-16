class HomeController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]

  def test
    FlickRaw.api_key = FLICKER_API_KEY
    FlickRaw.shared_secret = FLICKER_SHARED_SECRET
    flickr = FlickRaw::Flickr.new
    logger.debug(params)
    token = flickr.get_request_token(:oauth_callback => 'http://uplo.heroku.com/flickr_response')
    auth_url = flickr.get_authorize_url(token['oauth_token'], token['oauth_token_secret'], :perms => 'write')
    redirect_to auth_url
  end

  # response: { "oauth_token"=>"72157629828499297-421d9d93795a9b2b",
  #             "oauth_verifier"=>"c1ae746b4a78bb78",
  #             "controller"=>"home", "action"=>"flickr_response"}
  def flickr_response
    logger.debug('#####')
    logger.debug(params)
    logger.debug('#####')
    render :text => "here is response from flickr: #{params.inspect}"
  end

  def index
    session[:back_url] = url_for(:controller => 'home', :action => "browse") if session[:back_url].nil?
    @images = Image.load_popular_images(@filtered_params)
    if user_signed_in?
      redirect_to :action => :spotlight
    end
  end

  def browse
    @images = Image.load_popular_images(@filtered_params)
    render :template => 'home/new_browse', :layout => "main"
  end

  def spotlight
    @images = Image.load_popular_images(@filtered_params)
    render :layout => "main"
  end

  def intro
    render :layout => "main"
  end

  def popular
    session[:back_url] = url_for(:controller => 'home', :action => "browse") if session[:back_url].nil?
    @images = Image.load_popular_images(@filtered_params)
    render :layout => "main"
  end

  def search
    @no_async_image_tag = true
    limit_filtered_params = @filtered_params
    limit_filtered_params[:page_size] = 3
    @users = User.do_search({:query => URI.unescape(params[:query]), :filtered_params => limit_filtered_params})
    @galleries = Gallery.do_search({:query => URI.unescape(params[:query]), :filtered_params => limit_filtered_params})
    @images = Image.do_search({:query => URI.unescape(params[:query]), :filtered_params => @filtered_params})
  end

  protected

  def set_current_tab
    tab = "popular"
    browse_actions = ["browse", "search"]
    unless browse_actions.index(params[:action]).nil?
      tab = "browse"
    end
    @current_tab = tab
  end

  def default_page_size
    size = 30
    if params[:action] == "browse"
      size = 24
    elsif params[:action] == "search" || params[:action] == "spotlight"
      size = 12
    end
    return size
  end
end
