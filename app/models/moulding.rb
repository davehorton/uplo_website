class Moulding < ActiveRecord::Base
  validates :name, presence: true

  has_many :products

  default_scope order('mouldings.id')

  def self.in_product
    where(id: Product.all.map(&:moulding_id))
  end
end
