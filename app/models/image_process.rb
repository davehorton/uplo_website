class ImageProcess < ActiveRecord::Base
  def self.crop(img_path)
    img = Magick::Image.read(img_path).first
    width = img.columns
    height = img.rows
    if width == height
      return img_path
    elsif width < height
      size = width
    else
      size = height
    end

    start_x = width/2 - size/2
    start_y = height/2 - size/2
    cropped_img = img.crop start_x, start_y, size, size
    cropped_img_path = "#{ Rails.root }/tmp/#{ Time.now.strftime('%Y%m%d%H%M%S%9N') }"
    cropped_img.write cropped_img_path
    return cropped_img_path
  end
end
