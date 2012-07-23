class Admin::FlaggedUsersController < Admin::AdminController
  def index
  
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
    def select_tab
      @current_tab = "flagged_users"
    end
end
