class Size < ActiveRecord::Base
  validates :width, presence: true
  validates :height, presence: true

  has_many :products

  after_save :expire_cached_entries

  scope :by_width_height, order('sizes.width, sizes.height')

  def self.rectangular
    Rails.cache.fetch :rectangular_sizes do
      where("sizes.width <> sizes.height").by_width_height
    end
  end

  def self.square
    Rails.cache.fetch :square_sizes do
      where("sizes.width = sizes.height").by_width_height
    end
  end

  def to_name
    "#{width}x#{height}"
  end

  def to_recommended_pixels
    "#{minimum_recommended_resolution[:w]}x#{minimum_recommended_resolution[:h]}"
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

  private

    def expire_cached_entries
      Rails.cache.delete(:rectangular_sizes)
      Rails.cache.delete(:square_sizes)
    end
end
