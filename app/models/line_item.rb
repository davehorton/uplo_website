class LineItem < ActiveRecord::Base
  belongs_to :image
  belongs_to :product
  belongs_to :order

  validates :quantity, numericality: { less_than_or_equal_to: 10 }

  delegate :image_thumb_url, :image_url, :to => :image
  delegate :name, :to => :image, :prefix => true

  before_save :calculate_totals

  def total_price
    price * quantity
  end

  private

    def calculate_totals
      self.price = product.price_for_tier(image.tier_id)
      self.tax   = self.price * PER_TAX
      self.commission_percent = product.commission_for_tier(image.tier_id)
    end
end
