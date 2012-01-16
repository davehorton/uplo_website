class Order < ActiveRecord::Base
  belongs_to :user
  has_many :line_items, :dependent => :destroy
  
  def compute_totals
    self.price_total = compute_image_total
    self.tax = self.price_total * PER_TAX
    self.order_total = self.price_total + self.tax
    self.save
  end
  
  
  def compute_image_total
    items_with_gifts = line_items.select{ |item| !item.price.nil? }
    items_with_gifts.inject(0) {|sum, g| sum += g.price }
  end
end
