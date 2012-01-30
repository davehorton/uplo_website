class ShoppingCartController < ApplicationController
  before_filter :get_cart
    
  def clear
    @cart.clear
    session[:cart] = nil unless current_user
    redirect_to :action => 'show'
  end
  
  def show
    @line_items = @cart.order.line_items.find(:all, :include => [:order, :image], :order => "line_items.updated_at DESC, line_items.created_at DESC")
    @order = @cart.order
    @order.compute_totals
  end
  
  def add_to_cart
    image = Image.find_by_id params[:line_item][:image_id]
    params[:line_item].delete(:image_id)

    if image.nil?
      flash[:warning] = "Your recent ordered image does not exist anymore."
      redirect_to :controller => :home, :action => :browse and return
    elsif not valid_item?(params[:line_item])
      flash[:warning] = "Please fill all options first."
      redirect_to :controller => :images, :action => :order, :id => image.id and return
    else
      line_item = LineItem.new do |item|
        item.image = image
        item.plexi_mount = params[:line_item][:plexi_mount]
        item.size = params[:line_item][:size]
        item.moulding = params[:line_item][:moulding]
        item.price = 10#(image.price.nil? ? '0' : image.price)
        @cart.order.line_items << item
        @cart.save
      end
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
    item = LineItem.find(params[:id])
    if @cart.order.line_items.include?(item)
      item.destroy
    end
    redirect_to :action => "show"
  end
  
  
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
    unless @cart
      new_order = Order.create(:user => current_user)
      @cart = Cart.create({:order => new_order, :user => current_user})
      session[:cart] = @cart.id
    end
    
    return @cart
  end

  def valid_item?(hash)
    required_fields = ["plexi_mount", "size", "moulding"]
    required_fields.each { |k| return false if hash.has_key?(k)==false }
    return true
  end
end
