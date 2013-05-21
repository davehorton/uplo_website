class ApplicationController < ActionController::Base
  class_attribute :per_page
  self.per_page = 10 # Override in other controllers as needed

  protect_from_forgery

  layout 'main'

  rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
  rescue_from CanCan::AccessDenied,         :with => :render_unauthorized

  before_filter :authenticate_user!
  before_filter :set_current_tab, :check_banned_user

  helper_method :gallery_owner
  helper_method :image_owner
  helper_method :check_current_user

  def image_owner
    current_user || @image.user
  end

  def gallery_owner
    @gallery && @gallery.user == current_user
  end

  def result_hash
    @result_hash ||= {}
  end

  def render_not_found
    render_error_response("public/404.html", :not_found)
  end

  def render_unauthorized
    render_error_response("public/403.html", :unauthorized)
  end

  def render_banned_message
    render_error_response("public/banned_user.html", :unauthorized)
  end

  def render_error_response(file, response_code)
    render(file: file, status: response_code, layout: false) and return
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

  def after_sign_in_path_for(resource)
    "/"
  end

  def sticky_flash_message_key
    :sticky_flash_message
  end
  helper_method :sticky_flash_message_key

  def has_payment_profile?
    current_user && current_user.an_customer_payment_profile_id
  end
  helper_method :has_payment_profile?

  def sticky_flash_message?
    @sticky_flash_message ||= flash.delete(sticky_flash_message_key)
  end
  helper_method :sticky_flash_message?

  protected

    def apply_user_scope
      if current_user.try(:admin?)
        User.unscoped { yield }
      else
        yield
      end
    end

    def filtered_params
      @filtered_params ||= begin
        filtered_params = params
        filtered_params[:per_page] ||= per_page
        filtered_params
      end
    end

    # To show notification popup or not.
    def toggle_notification(visible)
      @notification_visible = visible
    end

    def hide_notification
      toggle_notification(false)
    end

    def show_notification
      toggle_notification(true)
    end

    def set_current_tab
      "please override this method in your sub class"
      # @current_tab = "home"
    end

    def check_banned_user
      if current_user && !current_user.admin? && current_user.blocked?
        render_banned_message
      end
    end

    def set_expiration(options)
      expires_on = Date.civil(options["expiration(1i)"].to_i, options["expiration(2i)"].to_i, 1)
      ["expiration(1i)", "expiration(2i)", "expiration(3i)"].each { |attr| options.delete(attr)}
      options[:expiration] = expires_on.strftime("%m-%Y")
    end
end
