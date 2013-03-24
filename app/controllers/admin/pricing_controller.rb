class Admin::PricingController < Admin::AdminController
  expose(:product)

  protected

    def set_current_tab
      @current_tab = "pricing"
    end
end