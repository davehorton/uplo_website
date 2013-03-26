class Product < ActiveRecord::Base
  belongs_to :moulding
  belongs_to :size

  validates :moulding, presence: true
  validates :size, presence: true
  validates :tier1_price, presence: true
  validates :tier2_price, presence: true
  validates :tier3_price, presence: true
  validates :tier4_price, presence: true
  validates :tier1_commission, presence: true
  validates :tier2_commission, presence: true
  validates :tier3_commission, presence: true
  validates :tier4_commission, presence: true

  default_scope joins(:size, :moulding).order('sizes.width, sizes.height, mouldings.id').readonly(false)

  def self.in_sizes(sizes)
    where(size_id: sizes)
  end

  def price_for_tier(tier_id)
    send(:"tier#{tier_id}_price")
  end

  def commission_for_tier(tier_id)
    send(:"tier#{tier_id}_commission")
  end

  def associated_with_any_orders?
    LineItem.where(product_id: self.id).exists?
  end
end
