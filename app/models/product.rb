class Product < ActiveRecord::Base
  belongs_to :moulding
  belongs_to :size
  belongs_to :tier

  validates :moulding, presence: true
  validates :size, presence: true
  validates :tier, presence: true
  validates :price, presence: true
  validates :commission, presence: true

  default_scope joins(:tier, :size, :moulding).order('tiers.name, sizes.width, sizes.height, mouldings.name').readonly(false)
end
