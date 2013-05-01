class Admin::SizesController < Admin::AdminController
  expose(:size)

  def index
    @sizes = Size.by_width_height.all
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

  def rebuild_photos
    Image.delay.rebuild_all_photos
    flash[:notice] = "Images scheduled for reprocessing."
    redirect_to admin_sizes_path
  end

  protected

    def set_current_tab
      @current_tab = "products"
    end
end