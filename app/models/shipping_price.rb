class ShippingPrice < ActiveRecord::Base
  belongs_to :product

  default_scope joins(:product => :size).order('sizes.height, sizes.width').readonly(false)
end
