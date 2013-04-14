class Admin::ImageToolsController < Admin::AdminController
  def index
  end

  def low_res_tool
    @too_small_images = []

    Image.unflagged.find_each do |image|
      @too_small_images << image if image.available_sizes.none?
    end
  end

  protected

    def set_current_tab
      @current_tab = "image_tools"
    end
end