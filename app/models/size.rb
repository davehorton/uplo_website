class Size < ActiveRecord::Base
  validates :width, presence: true
  validates :height, presence: true

  has_many :products

  default_scope order('sizes.width, sizes.height')
  scope :rectangular, where("sizes.width <> sizes.height")
  scope :square,      where("sizes.width = sizes.height")

  def to_name
    "#{width}x#{height}"
  end

  def to_a
    [ width, height ]
  end

  def aspect_ratio
    Paperclip::Geometry.new(width, height).aspect
  end

  def rectangular?
    width != height
  end

  def square?
    width == height
  end

  # returns a hash consisting of a width and height;
  # values are either based on stored values or, if not set,
  # a calculation based on a DPI of 150
  def minimum_recommended_resolution(dpi = 150)
    @minimum_recommended_resolution ||=
      { w: (minimum_recommended_width || dpi*width), h: (minimum_recommended_height || dpi*height) }
  end
end
