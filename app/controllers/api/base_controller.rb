# Contains base methods for all API controllers.
class Api::BaseController < ActionController::Base
  before_filter :setup_device_call
  before_filter :filter_params
  before_filter :set_global_variable
  
  PAGE_SIZE = 20
  MAX_PAGE_SIZE = 100
  
  protected
  
  def setup_device_call
    request.format = :json
  end
  
  def filter_params
    # TODO: filter paging info and other necessary parameters.
    @filtered_params = params
    @filtered_params = @filtered_params.symbolize_keys
    # Check the page_size params.
    if @filtered_params[:page_size].to_i <= 0
      @filtered_params[:page_size] = PAGE_SIZE
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
  
  def set_global_variable
    @result = {:success => false}
    @user = current_user
  end
end
