class Api::OrdersController < Api::BaseController
  # before_filter :require_login!

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

  # params: order_id:1, image_id:299, moulding:4, size:8x8, quantity:1
  def add_ordered_item
    image = Image.find_by_id params[:image_id]
    if image.nil? || image.image_flags.count > 0
      @result[:success] = false
      @result[:msg] = "Your recent ordered image does not exist anymore."
    elsif not valid_item?(params)
      @result[:success] = false
      @result[:msg] = "Please fill all options first."

    #check moulding & size constrain
    elsif Image::MOULDING_SIZES_CONSTRAIN.has_key?(params[:moulding]) and Image::MOULDING_SIZES_CONSTRAIN[params[:moulding]].index(params[:size])
      @result[:success] = false
      @result[:msg] = "The mould is not compatible with this size. Please change your options."

    else
      line_item = LineItem.new do |item|
        item.attributes = params
        item.price = image.get_price(image.tier, params[:size], params[:moulding])
        item.tax = item.price * PER_TAX
        if item.save
          @result[:success] = true
        else
          @result[:success] = false
          @result[:msg] = item.errors.full_messages.to_sentence
        end
      end
    end

    render :json => @result
  end

  # params: id:2, order_id:1, image_id:299, moulding:4, size:8x8, quantity:1
  def update_ordered_item
    item = LineItem.find_by_id params.delete(:id)

    if item.nil?
      @result[:success] = false
      @result[:msg] = "Your recent ordered image does not exist anymore."
    elsif not valid_item?(params)
      @result[:success] = false
      @result[:msg] = "Please fill all options first."

    #check moulding & size constrain
    elsif Image::MOULDING_SIZES_CONSTRAIN.has_key?(params[:moulding]) and Image::MOULDING_SIZES_CONSTRAIN[params[:moulding]].index(params[:size])
      @result[:success] = false
      @result[:msg] = "The mould is not compatible with this size. Please change your options."

    else
      image = item.image
      item.attributes = params
      item.price = image.get_price image.tier, params[:size], params[:moulding]
      item.tax = item.price * PER_TAX
      if item.save
        @result[:success] = true
      else
        @result[:success] = false
        @result[:msg] = item.errors.full_messages.to_sentence
      end
    end

    render :json => @result
  end

  # params: id:2
  def delete_ordered_item
    LineItem.delete_all :id => params[:id]
    render :json => {:success => true}
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
        response = an_value[:transaction].purchase(order.order_total, an_value[:credit_card])
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

  # POST: /api/finalize_order
  # params:
  # {order => {:id => 1, :transaction_code => "*", :transaction_status => "*"}
  def finalize_order
    order_info = params[:order]
    order = Order.find_by_id order_info.delete(:id)
    if order.nil?
      @result[:msg] = "This order does not exist anymore!"
      @result[:success] = false
      return render :json => @result
    end

    card_required_info = ['name_on_card', 'card_type', 'card_number', 'expiration']
    expires_on = Date.parse order_info[:expiration]
    order_info[:expiration] = expires_on.strftime("%m-%Y")
    order_info[:user] = @user

    # Checking requested information
    card_required_info.each { |val|
      if !params[:order].has_key?(val) || params[:order][val].blank?
        @result[:msg] = "Please fill all required fields first!"
        @result[:success] = false
        return render :json => @result
      end
    }

    order.transaction_date = Time.now
    card_string = order_info["card_number"]
    done = false
    if current_user.update_profile(order_info)
      order.compute_totals

      # TODO: update tax + price follow shipping state
      order.update_tax_by_state

      an_value = Payment.create_authorizenet_test(card_string, expires_on, {:shipping => order_info[:shipping_address_attributes], :address => order_info[:billing_address_attributes]})
      response = an_value[:transaction].purchase(order.order_total, an_value[:credit_card])
      success = !response.nil? && response.success?

      if success
        if order.finalize_transaction
          @result[:transaction_id] = response.transaction_id
          done = true
        end
      else
        @result[:success] = false
        @result[:msg] = 'Failed to make purchase.'
        return render :json => @result
      end
    else
      @result[:success] = false
      @result[:msg] = current_user.errors.full_messages.to_sentence
      return render :json => @result
    end

    @result[:success] = done
    @result[:msg] = order.errors.full_messages.to_sentence if !done

    return render :json => @result
  end

  # GET /api/show_cart
  # PARAMS id
  def show_cart
    order = Order.find_by_id params[:id]
    if order.nil?
      @result[:msg] = "This order does not exist anymore!"
      @result[:success] = false
      return render :json => @result
    end
    return render :json => {:success => true, :data => order.line_items}
  end

  protected
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

    # items: [{"image_id":1, "moulding":1, "size":"500x500", "quantity":"5"}]
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
