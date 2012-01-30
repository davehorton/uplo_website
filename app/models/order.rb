class Order < ActiveRecord::Base
  include ::SharedMethods::Paging
  include ::SharedMethods::SerializationConfig
  
  # ASSOCIATIONS
  belongs_to :user
  has_one :cart
  has_many :line_items, :dependent => :destroy
  has_many :images, :through => :line_items
  
  # CALLBACK
  before_create :init_transaction_date
  STATUS = {
    :shopping => "shopping",
    :checkout => "checkout",
    :complete => "completed"
  }
  TRANSACTION_STATUS = {
    :processing => "processing",
    :complete => "completed"
  }
  
  # CLASS METHODS
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
      [ :id, :user_id, :tax, :price_total, :order_total, :transaction_code, 
        :transaction_date, :transaction_status, :receiver_name, :address, :message, :delivery_time]
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
  
  # PUBLIC INSTANCE METHODS
  
  def compute_totals
    self.price_total = compute_image_total
    self.tax = self.price_total * PER_TAX
    self.order_total = self.price_total + self.tax
    self.save
  end  
  
  def compute_image_total
    items_with_gifts = line_items.select{ |item| !item.price.nil? }
    items_with_gifts.inject(0) {|sum, g| sum += g.price }
  end
  
  # PROTECTED METHODS
  protected
  
  def init_transaction_date
    if self.transaction_date.blank?
      self.transaction_date = Time.now
    end
    return self.transaction_date
  end
  
end
