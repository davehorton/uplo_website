class LineItem < ActiveRecord::Base
  belongs_to :image
  belongs_to :order

  validates :quantity, numericality: { less_than_or_equal_to: 10 }

  def image_thumb_url
    self.image.image_thumb_url
  end

  def image_url
    self.image.image_url
  end

  def image_name
    self.image.name
  end
end
