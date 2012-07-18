class Admin::AdminController < ApplicationController
  layout "main"
  
  before_filter :authenticate_user!
  before_filter :select_tab
  
  def index
    redirect_to '/admin/flagged_images'
  end
end
