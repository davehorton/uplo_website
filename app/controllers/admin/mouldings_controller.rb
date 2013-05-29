class Admin::MouldingsController < Admin::AdminController
  expose(:moulding)

  def index
  end

  def create
    if moulding.save
      redirect_to admin_mouldings_path
    else
      render :new
    end
  end

  def update
    if moulding.save
      redirect_to admin_mouldings_path
    else
      render :edit
    end
  end

  protected

    def set_current_tab
      @current_tab = "products"
    end
end
