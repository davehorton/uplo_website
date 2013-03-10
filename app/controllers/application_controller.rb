class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :show_processing
  before_filter :set_current_tab, :set_current_user, :check_banned_user, :set_auto_hide
  before_filter :filter_params

  layout 'main'

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

  def render_banned_message
    render :file => "public/banned_user.html", :status => :unauthorized, :layout => false
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
    "/" # <- Path you want to redirect the user to.
  end

  protected

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

    # To let user know how many images is processing
    def show_processing
      flash.delete :processing_photo
      if (current_user && current_user.photo_processing)
        number = current_user.images.processing.count
        if (number > 0)
          flash[:processing_photo] = "We are processing your images. This can take up to 3 minutes. We will notice you when it's done."
          flash[:auto_hide_notification] = false
        end

        if (number == 0)
          current_user.update_attribute(:photo_processing , false)
          flash[:processing_photo] = "Your images have been successfully processed!"
          flash[:auto_hide_notification] = false
        end
      end
    end

    def set_current_tab
      "please override this method in your sub class"
      # @current_tab = "home"
    end

    def set_current_user
      User.current_user = current_user
    end

    def set_auto_hide
      @auto_hide_notification = true
      if !flash[:auto_hide_notification].nil?
        @auto_hide_notification = flash[:auto_hide_notification]
        flash.delete(:auto_hide_notification)
      end
    end

    # You can override this method in the sub class.
    def default_page_size
      PAGE_SIZE
    end

    def filtered_params
      @filtered_params
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

    def check_banned_user
      if current_user && !current_user.admin? && current_user.blocked?
        render_banned_message
      end
    end
end
