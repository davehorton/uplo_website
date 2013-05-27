class Admin::ShippingPricesController < Admin::AdminController
  expose(:shipping_price)

  def index
  end

  def create
    if shipping_price.save
      redirect_to admin_shipping_prices_path
    else
      render :new
    end
  end

  def update
    if shipping_price.save
      redirect_to admin_shipping_prices_path
    else
      render :edit
    end
  end

  def destroy
    shipping_price.destroy
    redirect_to admin_shipping_prices_path
  end

  protected

    def set_current_tab
      @current_tab = "shipping_prices"
    end
end