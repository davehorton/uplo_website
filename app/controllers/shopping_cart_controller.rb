class ShoppingCartController < ApplicationController
  before_filter :get_cart

  def clear
    @cart.clear
    redirect_to :action => 'show'
  end

  def show
    if @cart.order
      @line_items = @cart.order.line_items.includes(:image, :product).order("line_items.updated_at DESC, line_items.created_at DESC")
      @order = @cart.order
      @order.compute_totals
    end
  end

  def add_to_cart
    image = Image.find_by_id(params[:image_id])

    if(image.nil? || image.image_flags.count > 0)
      flash[:warning] = "Your recent ordered image does not exist anymore."
      redirect_to :controller => :home, :action => :browse and return
    elsif !valid_item?(params[:line_item])
      flash[:warning] = "Please fill all options first."
      redirect_to order_image_path(image) and return
    else
      product = Product.find(params[:line_item][:product_id])
      product_option = ProductOption.find(params[:line_item][:product_option_id])

      if params[:line_item_id].present?
        line_item = @cart.order.line_items.find(params[:line_item_id])
        line_item.quantity = params[:line_item][:quantity].to_i
      else
        line_item = @cart.order.line_items.where(product_id: product.id, product_option_id: product_option.id).first
        line_item = @cart.order.line_items.new(image_id: image.id)
        line_item.quantity = params[:line_item][:quantity].to_i
      end

      line_item.product_id = product.id
      line_item.product_option_id = params[:line_item][:product_option_id]

      if line_item.save
        @order = @cart.order.reload
        redirect_to :action => :show
      else
        flash[:warning] = line_item.errors.full_messages.to_sentence
        redirect_to order_image_path(image) and return
      end
    end
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
      redirect_to :action => "show", :warning => @order.errors.full_messages.to_sentence
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
        result = { :success => false, :msg => 'Item is not part of your order.' }
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
      @cart = current_user.init_cart
    end

    def valid_item?(hash)
      required_fields = ["product_id", "quantity"]
      required_fields.each { |k| return false if hash.has_key?(k)==false or hash[k].blank? }
      if hash["quantity"] =~ /^\d*$/
        return false if hash["quantity"].to_i<=0
      else
        return false
      end

      return true
    end
end
