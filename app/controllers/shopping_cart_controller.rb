class ShoppingCartController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_cart
  layout "main"

  def clear
    @cart.clear
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

    #check moulding & size constrain
    elsif Image::MOULDING_SIZES_CONSTRAIN.has_key?(params[:line_item]['moulding']) and Image::MOULDING_SIZES_CONSTRAIN[params[:line_item]['moulding']].index(params[:line_item]['size'])
      flash[:error] = "The mould is not compatible with this size. Please change your options."
      redirect_to :controller => :images, :action => :order, :id => image.id and return

    else
      # Find line_item to reuse line item which has the same image, size and mounding
      line_item = @cart.order.line_items.find(:first, :conditions => ["image_id = ? AND size = ? AND moulding = ?",params[:image_id], params[:line_item]['size'],  params[:line_item]['moulding']])
      if (line_item)
        line_item.quantity = line_item.quantity + params[:line_item]['quantity'].to_i
        line_item.price = image.get_price(params[:line_item]['moulding'], params[:line_item]['size'])
        line_item.tax = line_item.price * PER_TAX
        line_item.commission_percent = image.get_commission
        if line_item.save
          @order = @cart.order.reload
        else
          flash[:warning] = line_item.errors.full_messages.to_sentence
          redirect_to :controller => :images, :action => :order, :id => image.id and return
        end
      else
        line_item = @cart.order.line_items.new do |item|
          item.image = image
          item.attributes = params[:line_item]
          item.price = image.get_price(params[:line_item]['moulding'], params[:line_item]['size'])
          item.tax = item.price * PER_TAX
          item.commission_percent = image.get_commission
          if item.save
            @order = @cart.order.reload
          else
            flash[:warning] = item.errors.full_messages.to_sentence
            redirect_to :controller => :images, :action => :order, :id => image.id and return
          end
        end
      end
    end
    redirect_to :action => :show
  end

  def update_cart
    line_item = LineItem.find_by_id params[:line_item_id]

    if line_item.nil?
      flash[:warning] = "Your recent ordered image does not exist anymore."
    elsif not valid_item?(params[:line_item])
      flash[:warning] = "Please fill all options first."
      redirect_to :controller => :images, :action => :order, :id => line_item.image.id, :line_item => line_item.id and return

    #check moulding & size constrain
    elsif Image::MOULDING_SIZES_CONSTRAIN.has_key?(params[:line_item]['moulding']) and Image::MOULDING_SIZES_CONSTRAIN[params[:line_item]['moulding']].index(params[:line_item]['size'])
      flash[:error] = "The mould is not compatible with this size. Please change your options."
      redirect_to :controller => :images, :action => :order, :id => image.id and return

    else
      image = line_item.image
      line_item.attributes = params[:line_item]
      line_item.price = image.get_price(params[:line_item]['moulding'], params[:line_item]['size'])
      line_item.tax = line_item.price * PER_TAX
      line_item.commission_percent = image.get_commission
      if line_item.save
        @order = @cart.order.reload
      else
        flash[:warning] = line_item.errors.full_messages.to_sentence
        redirect_to :controller => :images, :action => :order, :id => image.id, :line_item => line_item.id and return
      end
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
    @order.update_tax_by_state
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
      @cart = current_user.init_cart
    end

    def valid_item?(hash)
      required_fields = ["size", "moulding", "quantity"]
      required_fields.each { |k| return false if hash.has_key?(k)==false or hash[k].blank? }
      if hash["quantity"] =~ /^\d*$/
        return false if hash["quantity"].to_i<=0
      else
        return false
      end

      return true
    end
end
