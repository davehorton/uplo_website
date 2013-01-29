# == Schema Information
#
# Table name: line_items
#
#  id          :integer          not null, primary key
#  order_id    :integer
#  image_id    :integer
#  quantity    :integer          default(0)
#  tax         :float            default(0.0)
#  price       :decimal(16, 2)   default(0.0)
#  plexi_mount :boolean          default(FALSE)
#  moulding    :string(255)
#  size        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class LineItem < ActiveRecord::Base
  include ::SharedMethods::Paging
  include ::SharedMethods::SerializationConfig

  belongs_to :order
  belongs_to :image
  after_save :update_order
  after_destroy :update_order

  validates :quantity, :numericality => { :less_than_or_equal_to => 10 }
  validate :item_uniq, :on => :update

  class << self
    def exposed_methods
      [:image_thumb_url, :image_name, :image_url]
    end

    def exposed_attributes
      [:id, :moulding, :size, :quantity, :price, :image_name, :image_id]
    end

    def exposed_associations
      []
    end
  end

  def image_thumb_url
    self.image.image_thumb_url
  end

  def image_url
    self.image.image_url
  end

  def image_name
    self.image.name
  end

  def creation_timestamp
    ::Util.distance_of_time_in_words_to_now(self.created_at)
  end

  def update_order
    self.order.compute_totals
  end

  def discount
    #new rule: base on price only, not discount rule anymore
    0
  end

  def discount_price
    self.discount * self.price
  end

  def price_with_discount
    self.price - self.discount_price
  end

  protected
    def item_uniq
      if LineItem.exists?(:order_id => self.order_id, :image_id => self.image_id, :plexi_mount => self.plexi_mount, :moulding => self.moulding, :size => self.size)
        errors[:base] = 'The size and moulding options have been ordered in another item. Please choose other options.'
        return false
      end
    end
end
