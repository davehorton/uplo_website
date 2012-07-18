class Admin::FlaggedImagesController < Admin::AdminController

  def index
  
  end
  
  protected
   def select_tab
     @current_tab = "#admin_menu li:contains(Flagged Images)"
   end
end
