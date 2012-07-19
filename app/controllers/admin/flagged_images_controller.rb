class Admin::FlaggedImagesController < Admin::AdminController

  def index
    @categories = [["Terms of Use Violation",1],
                  ["Copyright",2],
                  ["Nudity",3]]
  end
  
  def change_sort_type
  end
  
  protected
   def select_tab
     @current_tab = "#admin_menu li:contains(Flagged Images)"
   end
end
