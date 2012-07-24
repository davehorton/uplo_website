class ShoppingCartController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_cart
  layout "main"

  def clear
    @cart.clear
    session[:cart] = nil unless current_user
    redirect_to :action => 'show'
  end

  def show
    if @cart.order
      @line_items = @cart.order.line_items.find(:all, :include => [:order, :image], :order => "line_items.updated_at DESC, line_items.created_at DESC")
      @order = @cart.order
      @order.compute_totals
    end
  end

  def add_to_cart
    image = Image.find_by_id params[:image_id]
    params[:line_item].delete(:image_id)

    if(image.nil? || image.image_flags.count > 0)
      flash[:warning] = "Your recent ordered image does not exist anymore."
      redirect_to :controller => :home, :action => :browse and return
    elsif not valid_item?(params[:line_item])
      flash[:warning] = "Please fill all options first."
      redirect_to :controller => :images, :action => :order, :id => image.id and return
    else
      line_item = LineItem.new do |item|
        item.image = image
        item.attributes = params[:line_item]
        item.price = image.get_price(image.tier, params[:line_item]['size'])
        item.tax = item.price * item.quantity.to_i * PER_TAX
        @cart.order.line_items << item
        @cart.save
      end
      @order = @cart.order.reload
    end
    redirect_to :action => :show
  end

  def update_cart
    line_item = LineItem.find_by_id params[:line_item_id]

    if line_item.nil?
      flash[:warning] = "Your recent ordered image does not exist anymore."
    elsif not valid_item?(params[:line_item])
      flash[:warning] = "Please fill all options first."
      redirect_to :controller => :images, :action => :order, :id => image.id, :line_item => line_item.id and return
    else
      line_item.attributes = params[:line_item]
      line_item.save
      @order = @cart.order.reload
    end
    redirect_to :action => :show
  end

  def checkout
    unless @cart
      flash[:warning] = "Your shopping cart is empty."
      redirect_to :action => 'show' and return
    end
    show
    @cart.order.status = Order::STATUS[:checkout]
    @cart.order.save
    @order = @cart.order
    @order.compute_totals
    @order.transaction_status = Order::TRANSACTION_STATUS[:processing]

    if @order.save
      redirect_to :controller => "orders", :action => "index"
    else
      redirect_to :action => "show"
    end
  end

  def destroy_item
    if request.xhr?
      order = @cart.order
      cart_items = order.line_items
      item = LineItem.find_by_id params[:id]
      if item.nil?
        result = { :success => true, :cart_items => cart_items.count, :cart_amounts =>
          { :price_total => self.class.helpers.number_to_currency(order.price_total, {:precision => 2}),
            :tax => self.class.helpers.number_to_currency(order.tax, {:precision => 2}),
            :cart_total => self.class.helpers.number_to_currency(order.order_total, {:precision => 2})} }
      elsif cart_items.include?(item)
        item.destroy
        order.reload
        result = { :success => true, :cart_items => cart_items.count,:cart_amounts =>
          { :price_total => self.class.helpers.number_to_currency(order.price_total, {:precision => 2}),
            :tax => self.class.helpers.number_to_currency(order.tax, {:precision => 2}),
            :cart_total => self.class.helpers.number_to_currency(order.order_total, {:precision => 2})} }
      else
        result = { :success => false, :msg => 'This item is not belong to your oder!' }
      end

      render :json => result
    else
      redirect_to :action => :show
    end
  end

  protected
  # The member may or may not be logged in.
  # If the member is not logged in, get the cart from the session.
  # Otherwise, get it from the logged in member's member record.
  def get_cart
    unless current_user.nil?
      @cart = current_user.init_cart
    else
      @cart = init_cart
    end
  end

  def init_cart
    @cart = Cart.find_by_id(session[:cart]) if session[:cart]
    if @cart.blank?
      if current_user.cart.blank?
        @cart = Cart.new({:user => current_user})
      else
        @cart = current_user.cart
      end

      if @cart.order.blank?
        @cart.order = current_user.recent_empty_order
      end

      if @cart.changed?
        @cart.save
      end

      session[:cart] = @cart.id
    elsif @cart.order.blank?
      @cart.order = current_user.recent_empty_order
      @cart.save
    end

    return @cart
  end

  def valid_item?(hash)
    required_fields = ["plexi_mount", "size", "moulding", "quantity"]
    required_fields.each { |k| return false if hash.has_key?(k)==false }
    if hash["quantity"] =~ /^\d*$/
      return false if hash["quantity"].to_i<=0
    else
      return false
    end

    return true
  end

  def set_current_tab
    @current_tab = "browse"
  end
end
