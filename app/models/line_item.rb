class LineItem < ActiveRecord::Base
  include ::Shared::AttachmentMethods
  include ::Shared::QueryMethods

  attr_accessor :generate_ordered_print

  belongs_to :image
  belongs_to :product
  belongs_to :product_option
  belongs_to :order

  attr_protected :price

  has_attached_file :content,
                    styles: lambda { |attachment| attachment.instance.thumbnail_styles },
                    :storage => :dropbox,
                    :dropbox_credentials => "#{Rails.root}/config/dropbox.yml",
                    :dropbox_options => { :path => proc { |style| dropbox_path }  }

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

  def thumbnail_styles
    if generate_ordered_print
      Hash[product_option.ordered_print_image_name => product_option.image_options(self.image)]
    end
  end

  def save_image_to_dropbox
    self.generate_ordered_print = true
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

  def s3_expire_time
    Time.zone.now.beginning_of_day.since 25.hours
  end

  def dropbox_path
    "#{order.dropbox_order_root_path}/#{id}.#{content.original_filename.split('.').last}"
  end

  private

    def calculate_totals
      self.price = product.price_for_tier(image.tier_id, image.owner?(order.user))
      self.tax   = self.price * PER_TAX
      self.commission_percent = product.commission_for_tier(image.tier_id) if self.image.gallery.commission_percent?
    end
end
