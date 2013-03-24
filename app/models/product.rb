class Product < ActiveRecord::Base
  belongs_to :moulding
  belongs_to :size
  belongs_to :tier

  validates :moulding, presence: true
  validates :size, presence: true
  validates :tier, presence: true
  validates :price, presence: true
  validates :commission, presence: true
end
