class SalesController < ApplicationController
  before_filter :authenticate_user!
  
  def index
  
  end
  
  protected
  
  def set_current_tab
    @current_tab = "sales"
  end
end
