class LineItem < ActiveRecord::Base
  include ::SharedMethods::Paging
  include ::SharedMethods::SerializationConfig

  belongs_to :order
  belongs_to :image
  after_save :update_order
  after_destroy :update_order

  validates :quantity, :numericality => { :less_than_or_equal_to => 10 }

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
end
