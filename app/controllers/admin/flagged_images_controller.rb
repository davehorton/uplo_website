class Admin::FlaggedImagesController < Admin::AdminController

  def index
    if (params[:flag_type].nil?)
      params[:flag_type] = 1
    end    
    @flagged_images = Image.flagged.where("flag_type = ?", params[:flag_type]).load_images(filtered_params)
  end
  
  # Params:
  # flag_type
  
  def reinstate_all
    result = {}
    
    begin
      flagged_images = Image.flagged.where("flag_type = ?", params[:flag_type]).includes(:author)
      users = []
      flagged_images.each do |image|
        if image.reinstate
          users << image.author
        end
      end
      
      # Make the users collection unique
      users.uniq_by!(&:id)
      
      if !users.blank?
        # Async. send notification email per users
        Scheduler.delay do      
          users.each do |user|
            begin
              UserMailer.flagged_image_is_reinstated(user).deliver
            rescue Exception => exc
              ::Util.log_error(exc, "UserMailer.flagged_image_is_reinstated")
            end
          end
        end
      end
      
      result[:status] = 'ok'
      flash[:notice] = I18n.t("admin.notice_reinstate_images_succeeded")
      result[:redirect_url] = admin_flagged_images_path(:flag_type => params[:flag_type])
        
    rescue Exception => exc
      ::Util.log_error(exc, "Admin::FlaggedImagesController#reinstate_all")
      result[:status] = 'error'
      result[:message] = I18n.t("admin.error_reinstate_images_failed")
    end
    
    render(:json => result)
  end
  
  # Params:
  # flag_type
  
  def remove_all
    result = {}
    
    begin
      flagged_images = Image.flagged.where("flag_type = ?", params[:flag_type]).includes(:author)
      
      users = []
      flagged_images.each do |image|
        if image.update_attribute(:is_removed, true)
          users << image.author
        end
      end
      
      # Make the users collection unique
      users.uniq_by!(&:id)
      
      if !users.blank?
        # Async. send notification email per users
        Scheduler.delay do
          users.each do |user|
            begin
              UserMailer.flagged_image_is_removed(user).deliver
            rescue Exception => exc
              ::Util.log_error(exc, "UserMailer.flagged_image_is_removed")
            end
          end
        end
      end
    
      result[:status] = 'ok'
      flash[:notice] = I18n.t("admin.notice_remove_images_succeeded")
      result[:redirect_url] = admin_flagged_images_path(:flag_type => params[:flag_type])
      
    rescue Exception => exc
      ::Util.log_error(exc, "Admin::FlaggedImagesController#remove_all")
      result[:status] = 'error'
      result[:message] = I18n.t("admin.error_remove_images_failed")
    end
    
    render(:json => result)
  end
  
  # Params:
  # image_id
  def reinstate_image
    result = {}
    
    begin
      image = Image.flagged.find_by_id(params[:image_id])
      if image && image.reinstate
        UserMailer.flagged_image_is_reinstated(image.author, image).deliver
        result[:status] = 'ok'
        flash[:notice] = I18n.t("admin.notice_reinstate_image_succeeded")
        result[:redirect_url] = admin_flagged_images_path(:flag_type => params[:flag_type])
      else
        result[:status] = 'error'
        result[:message] = I18n.t("admin.error_reinstate_image_failed")
      end
    rescue Exception => exc
      ::Util.log_error(exc, "Admin::FlaggedImagesController#remove_all")
      result[:status] = 'error'
      result[:message] = I18n.t("admin.error_reinstate_image_failed")
    end
    
    render(:json => result)
  end  
  
  # Params:
  # image_id
  def remove_image
    result = {}
    
    begin
      image = Image.flagged.find_by_id(params[:image_id])
      if image && image.update_attribute(:is_removed, true)
        UserMailer.flagged_image_is_removed(image.author, image).deliver
        result[:status] = 'ok'
        flash[:notice] = I18n.t("admin.notice_remove_image_succeeded")
        result[:redirect_url] = admin_flagged_images_path(:flag_type => params[:flag_type])
      else
        result[:status] = 'error'
        result[:message] = I18n.t("admin.error_remove_image_failed")
      end
    rescue Exception => exc
      ::Util.log_error(exc, "Admin::FlaggedImagesController#remove_all")
      result[:status] = 'error'
      result[:message] = I18n.t("admin.error_remove_image_failed")
    end
    
    render(:json => result)
  end
  
  # Params:
  # image_id
  def get_image_popup
    image = Image.flagged.find_by_id(params[:image_id])
     result = {
        :success => false,
        :msg => ""
      }
    if (image && image.image_flags.count > 0)
      result[:success] = true
      result[:data] = render_to_string :partial => "admin/flagged_images/flagged_image_popup", :locals => {:flag => image.image_flags.first}
      
    else
      result[:success] = false
      result[:msg] = "The image is not available or not flagged"
    end
    
    render :json => result
  end
  
  protected
  
    def set_current_tab
      @current_tab = "flagged_images"
    end
    
    def default_page_size
      actions = ['index']
      if params[:action] == 'index'
        size = 12
      else
        size = 24
      end
      return size
    end
        
end
