module CartsHelper
  def total_line_items
    cart = current_user.nil? ? Cart.find_by_id(session[:cart]) : current_user.cart
    if cart && cart.order
      return cart.order.line_items.count
    else
      return 0
    end
  end
  
  def find_cart
    @cart = current_user.nil? ? Cart.find_by_id(session[:cart]) : current_user.cart
    if @cart.nil? or @cart.empty?
      flash[:warning] = "Sorry, your shopping cart is empty. (Did you already submit your order? Check your email for receipts.)"
      redirect_to :controller => 'shopping_cart', :action => 'show'
      false
    else
      true
    end
  end
end
