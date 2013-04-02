class LineItem < ActiveRecord::Base
  include ::Shared::QueryMethods

  belongs_to :image
  belongs_to :product
  belongs_to :order

  # for cropping
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h, :being_cropped
  after_update :reprocess_photo, :if => :being_cropped

  has_attached_file :content, :processors => [:cropper]

  validates :quantity, numericality: { less_than_or_equal_to: 10 }

  delegate :image_thumb_url, :image_url, :to => :image
  delegate :name, :to => :image, :prefix => true

  before_save :calculate_totals

  def self.sold_items
    LineItem.joins(:image, :order).where(orders: { transaction_status: Order::TRANSACTION_STATUS[:complete] })
  end

  def total_price
    (tax + price) * quantity
  end

  def set_crop_dimension(options)
    self.crop_dimension = "#{options[:crop_w]}x#{options[:crop_h]}+#{options[:crop_x]}+#{options[:crop_y]}"
  end

  def crop_selection
    self.crop_dimension.to_s.split(/[x,+]/)
  end

  def copy_image
    self.being_cropped = true
    self.crop_w, self.crop_h, self.crop_x, self.crop_y = self.crop_selection
    self.content = self.image.image
    self.save!
  end

  # croping
  def cropping?
    [crop_x, crop_y, crop_w, crop_h].all?(&:present?)
  end

  private

    def reprocess_photo
      self.being_cropped = false # important
      content.reprocess!
    end


    def calculate_totals
      self.price = product.price_for_tier(image.tier_id)
      self.tax   = self.price * PER_TAX
      self.commission_percent = product.commission_for_tier(image.tier_id)
    end
end
