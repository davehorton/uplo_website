class Order < ActiveRecord::Base
  include ::Shared::QueryMethods

  attr_protected :price_total, :order_total

  belongs_to :user
  belongs_to :shipping_address, :class_name => 'Address', :foreign_key => :shipping_address_id
  belongs_to :billing_address, :class_name => 'Address', :foreign_key => :billing_address_id
  has_one :cart, :dependent => :destroy
  has_many :line_items, :dependent => :destroy
  has_many :images, :through => :line_items

  accepts_nested_attributes_for :billing_address
  accepts_nested_attributes_for :shipping_address

  before_create :init_transaction_date
  after_save    :push_notification

  STATUS = {
    :shopping => "shopping",
    :checkout => "checkout",
    :complete => "completed",
    :failed => "failed"
  }

  TRANSACTION_STATUS = {
    :processing => "processing",
    :complete => "completed",
    :failed => "failed"
  }

  REGION_TAX = {
    :newyork => {:state_code => 'NY', :tax => 0.08875}
  }

  default_scope order('orders.transaction_date desc')
  scope :completed, where(transaction_status: TRANSACTION_STATUS[:complete])

  def update_tax_by_state
    has_tax  = false
    # considering shipping state
    if self.shipping_address
      has_tax = true if self.shipping_address.in_new_york?

    # considering billing state, 'cause of shipping to billing
    elsif self.billing_address
      has_tax = true if self.billing_address.in_new_york?
    end

    if has_tax
      self.tax = self.compute_image_total * REGION_TAX[:newyork][:tax]
      self.transaction do
        self.line_items.each do |line_item|
          line_item.tax = line_item.price * REGION_TAX[:newyork][:tax]
          line_item.save
        end
      end
    else
      self.tax = 0
    end
    self.save
  end

  def compute_totals
    self.price_total = self.compute_image_total
    #self.tax = self.compute_tax_total
    self.shipping_fee = SHIPPING_FEE
    self.order_total = self.price_total + (self.tax ||= 0) + self.shipping_fee
    self.save
  end

  def compute_image_total
    items_with_gifts = self.line_items.select{ |item| !item.price.nil? }
    items_with_gifts.inject(0) do |sum, g|
      sum += g.price * g.quantity.to_i
    end
  end

  # Finish a transaction
  def finalize_transaction(params = {})
    begin
      params.to_options!
      params.merge!({
        :transaction_status => TRANSACTION_STATUS[:complete],
        :status => STATUS[:complete]
      })

      self.update_attributes(params)
      self.add_to_dropbox

      PaymentMailer.delay.transaction_finish(id)
      PaymentMailer.delay.inform_new_order(id)

    rescue Exception => exc
      ExternalLogger.log_error(exc, "Finalizing transaction failed")
      raise
    end

    return true
  end

  def transaction_completed?
    return (self.transaction_status.to_s == TRANSACTION_STATUS[:complete])
  end

  def add_to_dropbox
    self.line_items.each do |line_item|
      line_item.delay.copy_image
    end
  end

  def dropbox_order_root_path
    "orders/#{id}"
  end

  protected

    def init_transaction_date
      if self.transaction_date.blank?
        self.transaction_date = Time.now
      end
      return self.transaction_date
    end

    def push_notification
      if self.transaction_status == TRANSACTION_STATUS[:complete]
        items = self.line_items.select('distinct image_id')
        items.each do |item|
          if self.user_id != item.image.user_id
            Notification.deliver_image_notification(item.image.id, self.user_id, Notification::TYPE[:purchase])
          end
        end
      end
    end
end
