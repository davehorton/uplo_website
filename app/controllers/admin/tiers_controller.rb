class Admin::TiersController < Admin::AdminController
  expose(:tier)

  def index
  end

  def create
    if tier.save
      redirect_to admin_tiers_path
    else
      render :new
    end
  end

  def update
    if tier.save
      redirect_to admin_tiers_path
    else
      render :edit
    end
  end

  protected

    def set_current_tab
      @current_tab = "products"
    end
end