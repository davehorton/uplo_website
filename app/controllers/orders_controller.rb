class OrdersController < ApplicationController
  def index
    if find_cart
      @order = @cart.order
    end    
  end

  private
    def find_cart
      @cart = Cart.find_by_id(session[:cart])
      if @cart.nil? or @cart.empty?
        flash[:warning] = "Sorry, your shopping cart is empty. (Did you already submit your order? Check your email for receipts.)"
        redirect_to :controller => 'shopping_cart', :action => 'show'
        false
      else
        true
      end
    end
end
