module CartsHelper
  def total_line_items
    cart = current_user.cart
    if cart && cart.order
      return cart.order.line_items.count
    else
      return 0
    end
  end

  def find_cart
    @cart = current_user.cart
    if @cart.nil? or @cart.empty?
      flash[:warning] = I18n.t("order.cart_empty")
      redirect_to :controller => 'shopping_cart', :action => 'show'
      false
    else
      true
    end
  end
end
