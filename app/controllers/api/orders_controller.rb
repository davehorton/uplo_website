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
    card_required_info = ['name_on_card', 'card_type', 'card_number', 'expiration']
    order_info = params[:order]
    expires_on = Date.parse order_info[:expiration]
    order_info[:expiration] = expires_on.strftime("%m-%Y")
    images = order_info.delete(:images)
    order_info[:user] = @user

    # Checking requested information
    card_required_info.each { |val|
      if !params[:order].has_key?(val) || params[:order][val].blank?
        @result[:msg] = "Please fill all required fields first!"
        @result[:success] = false
        render :json => @result and return
      end
    }

    order = Order.new(order_info)
    order_items = build_order_items(JSON.parse(images))
    order.transaction_date = Time.now
    order.line_items << order_items
    card_string = order_info["card_number"]
    done = false
    if current_user.update_profile(order_info)
      if order.valid?
        order.compute_totals
        an_value = Payment.create_authorizenet_test(card_string, expires_on, {:shipping => order_info[:shipping_address_attributes], :address => order_info[:billing_address_attributes]})
        response = an_value[:transaction].purchase(@order.order_total, an_value[:credit_card])
        success = !response.nil? && response.success?

        if success
          if order.finalize_transaction
            @result[:order_id] = order.id
            @result[:transaction_id] = response.transaction_id
            done = true
          end
        else
          @result[:success] = false
          @result[:msg] = 'Failed to make purchase.'
          return render :json => @result
        end
      end
    else
      @result[:success] = false
      @result[:msg] = current_user.errors.full_messages.to_sentence
      return render :json => @result
    end

    @result[:success] = done
    if !done
      @result[:msg] = order.errors.full_messages.to_sentence
    end

    return render :json => @result
  end

  protected
  # items: [{"image_id":1, "plexi_mount":"true", "size":"500x500", "moulding":"Wood", "quantity":"5"}]
  def build_order_items(items)
    result = []
    items.each do |item_info|
      line_item = LineItem.new do |item|
        image = Image.un_flagged.find_by_id item_info['image_id']
        unless image.nil?
          item.attributes = item_info
          item.price = image.get_price(image.tier, item_info["size"], item_info["moulding"])
          result << item
        end
      end
    end
    return result
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
