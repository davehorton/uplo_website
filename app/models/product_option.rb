class ProductOption < ActiveRecord::Base
  belongs_to :product

  default_scope order('id')

  # used by Image to generate preview images for a given product option
  def preview_image_name
    "preview_#{product.size.to_name}_#{description.parameterize}".to_sym
  end

  def ordered_print_image_name
    "order_#{product.size.to_name}_#{description.parameterize}".to_sym
  end

  def image_options(image, preview=false)
    size = product.size
    aspect_ratio = size.aspect_ratio
    dpi = size.dpi

    if preview
      width = 650.0
      height = width/aspect_ratio
    else
      width = size.minimum_recommended_resolution[:w]
      height = size.minimum_recommended_resolution[:h]
    end

    if image.image.height > image.image.width
      new_height = width
      new_width  = height
      height = new_height
      width = new_width
    end

    if preview
      preview_ratio = width/size.minimum_recommended_resolution[:w]
    else
      preview_ratio = 1.0
    end

    if border_top_bottom == 0 && border_left_right == 0
      convert_options = "-thumbnail #{width}x#{height}^ -gravity center -extent #{width}x#{height}"
    elsif border_top_bottom > 0 && border_left_right == 0
      top_border = border_top_bottom*dpi*preview_ratio
      convert_options = "-resize #{width}x#{height-top_border*2} -gravity center -background white -extent #{width}x#{height}"
    elsif border_top_bottom == 0 && border_left_right > 0
      sides_border = border_left_right*dpi*preview_ratio
      convert_options = "-resize #{width-sides_border*2}x#{height}\\> -gravity center -background white -extent #{width}x#{height}"
    else # border_top_bottom > 0 && border_left_right > 0
      sides_border = border_left_right*dpi*preview_ratio
      top_border = border_top_bottom*dpi*preview_ratio
      convert_options = "-resize #{width-sides_border*2}x#{height-top_border*2}^ -gravity center -background white -extent #{width-sides_border*2}x#{height-top_border*2} -bordercolor White -border #{sides_border}x#{top_border}"
    end

    # set geometry to empty string and manually run resize command so that
    # get an accurate result (Paperclip's geometric parse function is not accurate)
    { geometry: "", convert_options: convert_options }
  end
end
