class LineItem < ActiveRecord::Base
  include ::Shared::QueryMethods

  belongs_to :image
  belongs_to :product
  belongs_to :order

  # for cropping
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h, :crop_flag
  after_save :delayed_copy_image, :if => :crop_flag

  STORAGE_OPTIONS = if Rails.application.config.paperclip_defaults[:storage] == :s3
                      {path: "image/:image_id/orders/:order_id/:style/:id.:extension"}
                    else
                      { path: ":rails_root/public/system/image/:image_id/orders/:order_id/:style/:id.:extension",
                        url: "/system/image/:image_id/orders/:order_id/:style/:id.:extension" }
                    end

  has_attached_file :content, {
    styles: lambda {|attachment| {:cropped => (attachment.instance.dyn_style)}},
    processors: [:cropper]
  }.merge(STORAGE_OPTIONS)

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
    self.crop_flag = true
    self.crop_dimension = "#{options[:crop_w]}x#{options[:crop_h]}+#{options[:crop_x]}+#{options[:crop_y]}"
  end

  def cropped_dimensions
    self.crop_dimension.to_s.split(/[x,+]/).collect(&:to_i)
  end

  def delayed_copy_image
    self.delay.copy_image
  end

  def copy_image
    self.crop_flag = false
    self.crop_w, self.crop_h, self.crop_x, self.crop_y = self.cropped_dimensions
    self.content = download_remote_image
    self.save!
  end

  def download_remote_image
    storage = Rails.application.config.paperclip_defaults[:storage]
    if storage == :filesystem
      self.image.image
    else
      io = open(URI.parse(self.image.url))
      def io.original_filename; base_uri.path.split('/').last; end
      io.original_filename.blank? ? nil : io
    end
  rescue OpenURI::HTTPError => e
    nil
  end

  # croping
  def cropping?
    [crop_x, crop_y, crop_w, crop_h].all?(&:present?)
  end

  def dyn_style
    cropping? ? "#{crop_w}x#{crop_h}" : "#{image.image.width}x#{image.image.height}"
  end

  def s3_expire_time
    Time.zone.now.beginning_of_day.since 25.hours
  end

  def url(options = :cropped)
    storage = Rails.application.config.paperclip_defaults[:storage]
    case storage
      when :s3 then self.content.expiring_url(s3_expire_time, options)
      when :filesystem then content.url(options)
    end
  end

  private

    def calculate_totals
      self.price = product.price_for_tier(image.tier_id)
      self.tax   = self.price * PER_TAX
      self.commission_percent = product.commission_for_tier(image.tier_id)
    end
end
