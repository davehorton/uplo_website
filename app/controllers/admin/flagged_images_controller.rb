class Admin::FlaggedImagesController < Admin::AdminController

  def index
    if (params[:flag_type].nil?)
      params[:flag_type] = 1
    end
    @categories = [["Terms of Use Violation",1],
                  ["Copyright",2],
                  ["Nudity",3]]
    @flagged_images = Image.flagged.where("flag_type = #{params[:flag_type]}")
  end
  
  # Params:
  # flag_type
  
  def reinstate_all
    flagged_images = Image.flagged.where("flag_type = #{params[:flag_type]}")
    flagged_images.each {|image| image.image_flags.destroy_all}
    redirect_to :action => :index, :flag_type => params[:flag_type]
  end
  
  # Params:
  # flag_type
  
  def remove_all
    flagged_images = Image.flagged.where("flag_type = #{params[:flag_type]}")
    flagged_images.each {|image| image.is_removed = true; image.save;}
    redirect_to :action => :index, :flag_type => params[:flag_type]
  end
  
  # Params:
  # image_id
  def reinstate_image
    flagged_images = Image.flagged
    image = flagged_images.where("images.id = ?", params[:image_id]).first
    if (image)
      image.image_flags.destroy_all
    end
    redirect_to :action => :index, :flag_type => params[:flag_type]
  end
  
  
  # Params:
  # image_id
  def remove_image
    flagged_images = Image.flagged
    image = flagged_images.where("images.id = ?", params[:image_id]).first
    if (image)
      image.is_removed = true
      image.save
    end
    redirect_to :action => :index, :flag_type => params[:flag_type]
  end
  
  protected
    def select_tab
      @current_tab = "flagged_images"
    end
end
