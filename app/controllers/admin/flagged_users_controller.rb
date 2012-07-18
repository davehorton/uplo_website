class Admin::FlaggedUsersController < Admin::AdminController
  def index
  
  end
  
  protected
   def select_tab
     @current_tab = "#admin_menu li:contains(Flagged Users)"
   end
end
