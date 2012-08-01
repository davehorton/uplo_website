# Contains base methods for all API controllers.
class Api::BaseController < ActionController::Base
  before_filter :setup_device_call
  before_filter :set_current_user
  before_filter :filter_params
  before_filter :set_global_variable
  
  PAGE_SIZE = 20
  MAX_PAGE_SIZE = 100
  
  if (Rails.env.production? or Rails.env.staging?)
    rescue_from CanCan::AccessDenied, :with => :render_unauthorized  
    rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
  end
  
  def render_not_found(with_status_code = true)
    options = {:json => {:msg => I18n.t("common.error_resource_notfound"), :status => 404}}
    if with_status_code
      options[:status] = 401
    end
    
    render(options)
  end
  
  def render_unauthorized(with_status_code = true)
    options = {:json => {:msg => I18n.t("common.error_unauthorized"), :status => 403}}
    if with_status_code
      options[:status] = 403
    end
    
    render(options)
  end
  
  def render_require_login(with_status_code = true)
    options = {:json => {:msg => I18n.t("common.error_not_login"), :status => 401}}
    if with_status_code
      options[:status] = 401
    end
    
    render(options)
  end
  
  def require_login!
    if !user_signed_in?
      render_require_login(false)
    end
  end
  
  protected
  
  def setup_device_call
    request.format = :json
  end
  
  def set_current_user
    User.current_user = current_user
  end
    
  # You can override this method in the sub class.
  def default_page_size
    PAGE_SIZE
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
  
  def filtered_params
    @filtered_params
  end
  
  def set_global_variable
    @result = {:success => false}
    @user = current_user
  end
end
