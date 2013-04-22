class Api::BaseController < ActionController::Base
  class_attribute :per_page
  self.per_page = 20 # Override in other controllers as needed

  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
  rescue_from CanCan::AccessDenied,         :with => :render_unauthorized

  before_filter :require_login!

  def current_user_gallery
    @resource_not_found_key = "gallery.not_found"
    @current_user_gallery ||= current_user.galleries.find(params[:gallery_id] || params[:id])
  end

  def current_user_image
    @resource_not_found_key = "image.not_found"
    @current_user_image ||= current_user.images.find(params[:id])
  end

  def require_login!
    render_require_login if !user_signed_in?
  end

  def resource_not_found_key
    @resource_not_found_key ||= "common.error_resource_notfound"
  end

  def render_not_found
    render_error_response(:not_found, resource_not_found_key)
  end

  def render_require_login
    render_error_response(:unauthorized, "common.error_not_login")
  end

  def render_unauthorized
    render_error_response(:unauthorized, "common.error_unauthorized")
  end

  def render_error_response(i18n_key, response_code)
    render(json: { msg: I18n.t(i18n_key) }, status: response_code) and return
  end

  def api_response
    @api_response ||= {}
  end

  protected

    def filtered_params
      @filtered_params ||= begin
        filtered_params = params
        filtered_params[:per_page] ||= per_page
        filtered_params
      end
    end
end
