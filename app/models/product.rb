class Product < ActiveRecord::Base
  belongs_to :moulding
  belongs_to :size
  belongs_to :tier

  validates :price, presence: true
  validates :commission, presence: true
end
