class Admin::SpotlightsController < Admin::AdminController
  def index
  
  end
  
  protected
   def select_tab
     @current_tab = "#admin_menu li:contains(Promote to Spotlight)"
   end
end
