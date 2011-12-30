# Contains base methods for all API controllers.
class Api::BaseController < ActionController::Base
  before_filter :setup_device_call
  
  def setup_device_call
    request.format = :json
  end
end
