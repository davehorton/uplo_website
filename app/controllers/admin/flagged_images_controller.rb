class Admin::FlaggedImagesController < Admin::AdminController

  def index
    if (params[:flag_type].nil?)
      params[:flag_type] = 1
    end
    @categories = [["Terms of Use Violation",ImageFlag::FLAG_TYPE['terms_of_use_violation']],
                  ["Copyright",ImageFlag::FLAG_TYPE['copyright']],
                  ["Nudity",ImageFlag::FLAG_TYPE['nudity']]]
    @flagged_images = Image.flagged.where("flag_type = ?", params[:flag_type])
  end
  
  # Params:
  # flag_type
  
  def reinstate_all
    flagged_images = Image.flagged.where("flag_type = ?", params[:flag_type])
    flagged_images.each {|image| image.reinstate }
    redirect_to :action => :index, :flag_type => params[:flag_type]
  end
  
  # Params:
  # flag_type
  
  def remove_all
    flagged_images = Image.flagged.where("flag_type = ?", params[:flag_type])
    flagged_images.each {|image| image.is_removed = true; image.save;}
    redirect_to :action => :index, :flag_type => params[:flag_type]
  end
  
  # Params:
  # image_id
  def reinstate_image
    image = Image.flagged.find_by_id(params[:image_id])
    if (image)
      image.reinstate
    end
    redirect_to :action => :index, :flag_type => params[:flag_type]
  end  
  
  # Params:
  # image_id
  def remove_image
    image = Image.flagged.find_by_id(params[:image_id])
    if (image)
      image.is_removed = true
      image.save
    end
    redirect_to :action => :index, :flag_type => params[:flag_type]
  end
  
  protected
    def set_current_tab
      @current_tab = "flagged_images"
    end
end
