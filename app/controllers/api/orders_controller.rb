class Api::OrdersController < Api::BaseController
  before_filter :require_login!

  # GET: /api/list_orders
  # params:
  # result:
  #
  def list_orders
    orders = @user.orders.load_orders(@filtered_params)
    @result[:total] = orders.total_entries
    @result[:data] = orders_to_json(orders)
    @result[:success] = true
    render :json => @result
  end

  # POST: /api/create_order
  # params:
  # {order => {:images => "[{"image_id":1, "plexi_mount":"true", "size":"500x500", "moulding":"Wood", "quantity":"5"}]",
  #            :transaction_code => "*", :transaction_status => "*"}
  def create_order
    order_info = params[:order]
    images = order_info.delete(:images)
    order_info[:user] = @user
    order = Order.new(order_info)
    order_items = build_order_items(JSON.parse(images))

    done = false
    if order.valid?
      order.compute_totals
      if order.transaction_completed? && order.finalize_transaction
        @result[:order_id] = order.id
        @result[:success] = true
        done = true
      elsif order.save
        order.line_items << order_items
        @result[:order_id] = order.id
        @result[:success] = true
        done = true
      end
    end

    if !done
      @result[:msg] = order.errors
    end

    return render :json => @result
  end

  protected
  # items: [{"image_id":1, "plexi_mount":"true", "size":"500x500", "moulding":"Wood", "quantity":"5"}]
  def build_order_items(items)
    items = []
    items.each do |item_info|
      line_item = LineItem.new do |item|
        item.attributes = item_info
        item.price = (image.price.nil? ? '0' : image.price)
        items << item
      end
    end
    return items
  end

  def orders_to_json(orders)
    json_array = []

    orders.each do |order|
      data = {}
      data[:order] = order.serializable_hash({
        :except => order.except_attributes,
        :methods => order.exposed_methods,
      })

      data[:order][:images] = []
      order.images.each do |img|
        data[:order][:images] << img.serializable_hash(img.default_serializable_options)
      end

      json_array << data
    end

    return json_array
  end
end
