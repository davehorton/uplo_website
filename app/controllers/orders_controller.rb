class OrdersController < ApplicationController
  include CartsHelper

  def index
    if find_cart
      @order = @cart.order
      @order.set_addresses(current_user)
    end
  end

  def show
    @order = current_user.orders.find(params[:id])
  end
end
