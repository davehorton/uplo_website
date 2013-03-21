class OrdersController < ApplicationController
  include CartsHelper

  def index
    if find_cart
      @order = @cart.order
      @order.billing_address = Address.new if !@order.billing_address
      @order.shipping_address = Address.new if !@order.shipping_address
    end
  end
end
