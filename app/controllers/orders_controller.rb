class OrdersController < ApplicationController
  include CartsHelper

  before_filter :authenticate_user!
  layout 'main'

  def index
    if find_cart
      @order = @cart.order
    end
  end
end
