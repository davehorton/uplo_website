class Order < ActiveRecord::Base
  include ::SharedMethods::Paging
  include ::SharedMethods::SerializationConfig

  belongs_to :user
  belongs_to :shipping_address, :class_name => 'Address', :foreign_key => :shipping_address_id
  belongs_to :billing_address, :class_name => 'Address', :foreign_key => :billing_address_id
  has_one :cart, :dependent => :destroy
  has_many :line_items, :dependent => :destroy
  has_many :images, :through => :line_items

  accepts_nested_attributes_for :billing_address
  accepts_nested_attributes_for :shipping_address

  after_save :push_notification
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

  scope :completed_orders, where(:transaction_status => Order::TRANSACTION_STATUS[:complete])

  validates_length_of :cvv, :in => 3..4, :allow_nil => true
  validates_numericality_of :cvv, :card_number, :only_integer => true, :allow_nil => true

  class << self
    def load_orders(params = {})
      paging_info = parse_paging_options(params)
      self.includes([{:line_items => :image}]).paginate(
        :page => paging_info.page_id,
        :per_page => paging_info.page_size,
        :order => paging_info.sort_string)
    end

    def exposed_methods
      []
    end

    def exposed_attributes
      [ :id, :user_id, :tax, :price_total, :order_total,
        :transaction_code, :transaction_date, :transaction_status,
        :first_name, :last_name, :address, :message,
        :city, :zip_code, :card_type, :card_number, :expiration, :cvv]
    end

     def exposed_associations
      [:images]
    end

    protected

      def parse_paging_options(options, default_opts = {})
        if default_opts.blank?
          default_opts = {
            :sort_criteria => "orders.transaction_date DESC"
          }
        end
        paging_options(options, default_opts)
      end
  end

  def update_tax_by_state
    has_tax  = false
    # considering shipping state
    if self.shipping_address
      has_tax = true if self.shipping_address.state == Order::REGION_TAX[:newyork][:state_code]

    # considering billing state, 'cause of shipping to billing
    elsif self.billing_address
      has_tax = true if self.billing_address.state == Order::REGION_TAX[:newyork][:state_code]
    end

    if has_tax
      self.tax = (self.compute_image_total - self.compute_discount_total)* Order::REGION_TAX[:newyork][:tax]
      self.transaction do
        self.line_items.each do |line_item|
          line_item.tax = line_item.price_with_discount * Order::REGION_TAX[:newyork][:tax]
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
    self.order_total = self.price_total + (self.tax ||= 0) + self.shipping_fee - self.compute_discount_total
    self.save
  end

  def compute_discount_total
    #new rule: base on price only, not discount rule anymore
    0
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
        :transaction_status => Order::TRANSACTION_STATUS[:complete],
        :status => Order::STATUS[:complete]
      })

      # Update order attributes
      self.update_attributes(params)

      # Start shipping product

      # Send the notification email to the buyer.
      PaymentMailer.transaction_finish(self).deliver
      PaymentMailer.inform_new_order(self).deliver
    rescue Exception => exc
      ::Util.log_error(exc, "Finalizing transaction failed")
      raise
    end

    return true
  end

  def transaction_completed?
    return (self.transaction_status.to_s == TRANSACTION_STATUS[:complete])
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
          if self.user_id != item.image.author.id
            Notification.deliver_image_notification(item.image.id, self.user_id, Notification::TYPE[:purchase])
          end
        end
      end
    end
end
