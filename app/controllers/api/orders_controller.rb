class Api::OrdersController < Api::BaseController
  include ActiveMerchant::Billing::Integrations
  include CartsHelper

  # POST: /api/orders/add_item
  # required:
  #   item[image_id]
  #   item[product_id]
  #   item[product_option_id]
  #   item[quantity]
  def add_item
    item = params[:item]
    image = Image.find(item[:image_id])

    order = current_user.init_cart.order
    line_item = order.line_items.where(
      image_id: image.id,
      product_id: item[:product_id],
      product_option_id: item[:product_option_id]
    ).first

    if line_item.present?
      line_item.quantity += item[:quantity].to_i
    else
      line_item = order.line_items.build(item)
    end

    line_item.price = Product.find(line_item.product_id).price_for_tier(image.tier_id)
    line_item.tax = line_item.price * PER_TAX

    if line_item.save
      render json: line_item, status: :created
    else
      render json: { msg: line_item.errors.full_messages.to_sentence }, status: :bad_request
    end
  end

  # PUT: /api/orders/update_item
  # required:
  #   id
  #   item[image_id]
  #   item[product_id]
  #   item[quantity]
  def update_item
    order = current_user.init_cart.order
    line_item = order.line_items.find(params[:id])
    line_item.attributes = params[:item]
    image = line_item.image
    line_item.price = Product.find(line_item.product_id).price_for_tier(image.tier_id)
    line_item.tax = line_item.price * PER_TAX

    if line_item.save
      render json: line_item, status: :created
    else
      render json: { msg: line_item.errors.full_messages.to_sentence }, status: :bad_request
    end
  end

  # params: id:2
  def delete_ordered_item
    @result = {:success => true}
    item = LineItem.find_by_id params[:id]
    if item
      @result[:success] = false
      LineItem.transaction do
        item.order.compute_totals
        item.order.update_tax_by_state
        item.destroy
        @result[:success] = true
      end
      @result[:msg] = 'Cannot delete this item right now! Please try again later!' unless @result[:success]
    end
    render :json => @result
  end

  # POST: /api/orders
  # params:
  #   order hash
  def create
    order = current_user.init_cart.order
    order.compute_totals
    order_info = params[:order]
    credit_card = CreditCard.build_card_from_param(order_info)

    user_info = {}
    user_info[:billing_address_attributes] = order_info[:billing_address_attributes]
    user_info[:shipping_address_attributes] = order_info[:shipping_address_attributes]
    current_user.update_profile(user_info)

    response = Payment.process_purchase(current_user, order, credit_card)
    success = !response.nil? && response.success?

    if success
      order.finalize_transaction
      current_user.cart.try(:destroy)

      render json: { msg: "Order charged" }, status: :created
    else
      render json: { msg: "Problem charging your card." }, status: :bad_request
    end
  rescue Exception => ex
    ExternalLogger.new.log_error(ex, "Problem charging card for order #{order.try(:id)}.")
    render json: { msg: ex.message }, status: :bad_request
  end

  # GET /api/orders/cart
  def cart
    order = current_user.init_cart.order
    if order.nil?
      render json: { msg: "This order does not exist anymore!" }, status: :not_found
    else
      render json: order
    end
  end

  protected

    def finalize_cart
      if find_cart
        @order = @cart.order
        @order.finalize_transaction
        @order.save
        @cart.destroy if @cart
      end
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

    # items: [{"image_id":1, "moulding":1, "size":"500x500", "quantity":"5"}]
    def build_order_items(items)
      result = []
      items.each do |item_info|
        line_item = LineItem.new do |item|
          image = Image.unflagged.find_by_id item_info['image_id']
          unless image.nil?
            item.attributes = item_info
            item.price = image.get_price(item_info["moulding"], item_info["size"])
            result << item
          end
        end
      end
      return result
    end
end
