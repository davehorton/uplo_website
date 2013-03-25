class Moulding < ActiveRecord::Base
  validates :name, presence: true

  default_scope order('mouldings.id')

  def self.in_product
    where(id: Product.all.map(&:moulding_id))
  end
end
