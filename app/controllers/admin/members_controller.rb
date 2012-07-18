class Admin::MembersController < Admin::AdminController
  def index
  
  end
  
  protected
   def select_tab
     @current_tab = "#admin_menu li:contains(Member Profiles)"
   end
end
