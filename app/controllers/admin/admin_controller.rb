class Admin::AdminController < ApplicationController
  layout "main"
  
  before_filter :authenticate_user!
  
  def index
    redirect_to '/admin/flagged_images'
  end
end
