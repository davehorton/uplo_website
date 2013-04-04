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
    self.width != self.height
  end

  def square?
    self.width == self.height
  end
end
