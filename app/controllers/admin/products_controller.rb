class Admin::ProductsController < Admin::AdminController
  expose(:product)

  def index
  end

  def create
    if product.save
      redirect_to admin_products_path
    else
      render :new
    end
  end

  def update
    if product.save
      flash[:notice] = "Product updated"
      redirect_to admin_products_path
    else
      render :edit
    end
  end

  protected

    def set_current_tab
      @current_tab = "products"
    end
end