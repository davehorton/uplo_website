class Size < ActiveRecord::Base
  validates :name, presence: true
  validates :width, presence: true
  validates :height, presence: true
  default_scope order('sizes.width, sizes.height')
end
