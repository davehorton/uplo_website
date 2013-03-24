class Admin::SizesController < Admin::AdminController
  expose(:size)

  def index
  end

  def create
    if size.save
      redirect_to admin_sizes_path
    else
      render :new
    end
  end

  def update
    if size.save
      redirect_to admin_sizes_path
    else
      render :edit
    end
  end

  protected

    def set_current_tab
      @current_tab = "products"
    end
end