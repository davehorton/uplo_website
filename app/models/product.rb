class Product < ActiveRecord::Base
  belongs_to :moulding
  belongs_to :size
  has_many   :product_options

  accepts_nested_attributes_for :product_options, :reject_if => :all_blank, :allow_destroy => true

  after_save :expire_cached_entries

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
  scope :private_gallery, where(private_gallery: true)
  scope :public_gallery, where(public_gallery: true)

  def self.for_sizes(sizes)
    where(size_id: sizes)
  end

  def self.for_rectangular_sizes
    where(size_id: Size.rectangular.map(&:id))
  end

  def self.for_square_sizes
    where(size_id: Size.square.map(&:id))
  end

  def price_for_tier(tier_id)
    send(:"tier#{tier_id || 1}_price")
  end

  def commission_for_tier(tier_id)
    send(:"tier#{tier_id || 1}_commission")
  end

  def associated_with_any_orders?
    LineItem.where(product_id: self.id).exists?
  end

  def display_name
    "#{size.to_name} - #{moulding.name}"
  end

  private

    def expire_cached_entries
      # brute approach since memcached doesn't support deleting of
      # keys using regex patterns; but fortunately products don't
      # change with enough frequency to make this a dangerous option
      Rails.cache.clear
    end
end
