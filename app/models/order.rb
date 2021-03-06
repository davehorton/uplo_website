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

  default_scope order('orders.updated_at desc')
  scope :completed,  where(status: STATUS[:complete])
  scope :in_cart,    where(status: [STATUS[:shopping], STATUS[:checkout]])
  scope :purchased, where(status: [STATUS[:complete], STATUS[:failed]])
  scope :with_items, where('orders.order_total > 0')

  def completed?
    status == STATUS[:complete]
  end

  def in_new_york?
    self.shipping_address.try(:in_new_york?) || self.billing_address.try(:in_new_york?)
  end

  def compute_totals
    self.price_total = self.compute_image_total
    self.tax = if self.in_new_york?
                 self.compute_image_total * REGION_TAX[:newyork][:tax]
               else
                 0
               end
    self.shipping_fee = calculate_shipping
    self.order_total = self.price_total + (self.tax ||= 0) + self.shipping_fee
    self.save
  end

  def calculate_shipping
    @calculate_shipping ||= begin
      total_shipping = 0.00

      line_items.includes(:product).each do |line_item|
        sp = ShippingPrice.where(product_id: line_item.product_id).where("quantity >= ?", line_item.quantity).all
        if sp.any?
          total_shipping += sp.first.amount
        else
          sp = ShippingPrice.where(product_id: line_item.product_id).all
          if sp.any?
            total_shipping += sp.last.amount
          end
        end
      end

      total_shipping
    end
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
      self.cart.assign_empty_order!

      PaymentMailer.delay.transaction_finish(id)
      PaymentMailer.delay.inform_new_order(id)
      self.push_notification

    rescue Exception => exc
      ExternalLogger.new.log_error(exc, "Finalizing transaction failed")
      raise
    end

    return true
  end

  def add_to_dropbox
    self.line_items.each do |line_item|
      line_item.delay.save_image_to_dropbox
    end
  end

  def dropbox_order_root_path
    "orders/#{id}"
  end

  # shipping address only exists if user does not want to
  # use billing address for deliveries
  def ship_to_address
    (shipping_address || user.shipping_address || user.billing_address).try(:full_address)
  end

  def push_notification
    if self.transaction_status == TRANSACTION_STATUS[:complete]
      items = self.line_items.select('distinct image_id')
      items.each do |item|
        if self.user_id != item.image.user_id
          Notification.deliver_image_notification(item.image_id, self.user_id, Notification::TYPE[:purchase])
        end
      end
    end
  end

  def billing_address_attributes=(options)
    options.delete(:id)
    (self.billing_address || self.build_billing_address).update_attributes(options)
  end

  def shipping_address_attributes=(options)
    options.delete(:id)
    (self.shipping_address || self.build_shipping_address).update_attributes(options)
  end

  def set_addresses(user)
    self.billing_address  ||= Address.new.initialize_dup(user.billing_address || Address.new)
    self.shipping_address ||= Address.new.initialize_dup(user.shipping_address || Address.new)
  end

  protected

    def init_transaction_date
      if self.transaction_date.blank?
        self.transaction_date = Time.now
      end
      return self.transaction_date
    end
end
