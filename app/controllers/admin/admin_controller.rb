class Admin::AdminController < ApplicationController
  layout "main"
  
  before_filter :authenticate_user!
  before_filter :select_tab
  
  def index
    redirect_to '/admin/flagged_images'
  end
  
  protected
   def select_tab
     @current_tab = "#admin_menu li:contains(Flagged Images)"
   end
end
