class Admin::FlaggedUsersController < Admin::AdminController
  def index
    @users = User.flagged_users.load_users(self.filtered_params)
  end
  
  def reinstate_all
  end
    
  def remove_all
  end
  
  # Reinstate all flagged images of a user.
  def reinstate_images
    user = User.find_by_id(params[:id])
    if user && user.reinstate_flagged_images
      
    end
  end
  
  # Remove all flagged images of a user.
  def remove_images
    user = User.find_by_id(params[:id])
    if user && user.remove_flagged_images
      
    end
  end
  
  protected
    def set_current_tab
      @current_tab = "flagged_users"
    end
    
    def default_page_size
      return 24
    end
end
