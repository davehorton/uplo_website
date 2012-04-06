class OrdersController < ApplicationController
  include CartsHelper
  
  before_filter :authenticate_user!
  
  def index
    if find_cart
      @order = @cart.order
    end    
    render :template => 'orders/index_new', :layout => 'main'
  end
  
  protected
  def set_current_tab
    @current_tab = "browse"
  end
end
