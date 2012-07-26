class Admin::FlaggedUsersController < Admin::AdminController
  def index
    @users = User.flagged_users.load_users(self.filtered_params)
  end
  
  def reinstate_all
    redirect_to :action => :index
  end
  
  # Params:
  # flag_type
  
  def remove_all
    redirect_to :action => :index
  end
  
  # Params:
  # image_id
  def reinstate_user
    redirect_to :action => :index
  end
  
  
  # Params:
  # image_id
  def remove_user
    redirect_to :action => :index
  end
  
  protected
    def set_current_tab
      @current_tab = "flagged_users"
    end
    
    def default_page_size
      return 24
    end
end
