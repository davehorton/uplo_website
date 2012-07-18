class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_current_tab
  before_filter :filter_params
  before_filter :store_current_user

  PAGE_SIZE = 10
  MAX_PAGE_SIZE = 100

  if (Rails.env.production? or Rails.env.staging?)
    rescue_from CanCan::AccessDenied, :with => :render_unauthorized
    rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
  end

  def render_not_found
    render :file => "public/404.html", :status => 404, :layout => false
  end

  def render_unauthorized
    render :file => "public/403.html", :status => :unauthorized, :layout => false
  end

  def push_redirect
    session[:back_url] = request.env["HTTP_REFERER"]
  end

  def redirect_back
    go_to = session[:back_url]
    if go_to
      session[:back_url] = nil
      redirect_to go_to
    else
      redirect_to "/"
    end
  end

  protected

  def set_current_tab
    "please override this method in your sub class"
    # @current_tab = "home"
  end

  # You can override this method in the sub class.
  def default_page_size
    PAGE_SIZE
  end
  
  def store_current_user
    if (!current_user.nil?)
      Image.set_current_user current_user
    end
  end

  def filter_params
    # TODO: filter paging info and other necessary parameters.
    @filtered_params = params
    @filtered_params = @filtered_params.symbolize_keys
    # Check the page_size params.
    if @filtered_params[:page_size].to_i <= 0
      @filtered_params[:page_size] = default_page_size
    elsif @filtered_params[:page_size].to_i > MAX_PAGE_SIZE
      @filtered_params[:page_size] = MAX_PAGE_SIZE
    end

    unless @filtered_params[:lang].blank?
      I18n.locale = @filtered_params[:lang]
    else
      I18n.locale = :en
    end

    return @filtered_params
  end
end
