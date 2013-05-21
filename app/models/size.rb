class Size < ActiveRecord::Base
  validates :width, presence: true
  validates :height, presence: true

  has_many :products

  after_save :expire_cached_entries

  scope :by_height_width, order('sizes.height, sizes.width')

  def self.rectangular
    Rails.cache.fetch :rectangular_sizes do
      where("sizes.width <> sizes.height").by_height_width
    end
  end

  def self.square
    Rails.cache.fetch :square_sizes do
      where("sizes.width = sizes.height").by_height_width
    end
  end

  def to_name
    "#{height}x#{width}"
  end

  def to_recommended_pixels
    "#{minimum_recommended_resolution[:h]}x#{minimum_recommended_resolution[:w]}"
  end

  def to_a
    [ height, width ]
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
      { w: (minimum_width_in_pixels || dpi*width), h: (minimum_height_in_pixels || dpi*height) }
  end

  private

    def expire_cached_entries
      Rails.cache.delete(:rectangular_sizes)
      Rails.cache.delete(:square_sizes)
    end
end
