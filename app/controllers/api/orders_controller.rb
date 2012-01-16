class Api::OrdersController < Api::BaseController
  before_filter :require_login!
  
  # GET: /api/orders
  # params: 
  # result:
  # 
  def index
    orders = @user.orders.load_orders(@filtered_params)
    @result[:total] = orders.total_entries    
    @result[:data] = orders
    @result[:success] = true
    render :json => @result
  end
  
  # POST: /api/orders
  # params: 
  # {order => {:images => [1, 2, 3, 4, 5], :transaction_code => "*", :transaction_status => "*"}}
  def create
    order_info = params[:order]
    image_ids = order_info.delete(:images)
    order_info[:user] = @user
    order = Order.new(order_info)
    order.line_items = build_order_items(image_ids)
    
    if order.save
      @result[:order] = order.id
      @result[:success] = true
    else
      @result[:msg] = order.errors 
    end
    
    return render :json => @result
  end
  
  protected
  
  def build_order_items(image_ids)
    items = []
    images = Image.where(:id => image_ids)
    images.each do |image|
      items << LineItem.new({
        :image => image,
        :price => image.price        
      })
    end
    return items
  end
end
