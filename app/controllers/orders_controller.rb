class OrdersController < ApplicationController
  include CartsHelper
  
  def index
    if find_cart
      @order = @cart.order
    end    
  end
end
