class OrdersController < ApplicationController
  include CartsHelper

  def index
    if find_cart
      @order = @cart.order
      @order.billing_address = Address.new.initialize_dup(@order.billing_address ||
                                                          current_user.billing_address ||
                                                          Address.new)

      @order.shipping_address = Address.new.initialize_dup(@order.shipping_address ||
                                                           current_user.shipping_address ||
                                                           Address.new)
    end
  end

  def show
    @order = current_user.orders.find(params[:id])
  end
end
