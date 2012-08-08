class Image < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include ::SharedMethods::Paging
  include ::SharedMethods::SerializationConfig
  include ::SharedMethods::Converter
  include ::SharedMethods

  FILTER_OPTIONS = ['date_uploaded', 'num_of_views', 'num_of_orders', 'num_of_likes']

  # ASSOCIATIONS
  belongs_to :gallery
  has_one :author, :through => :gallery, :source => :user
  has_many :image_flags, :dependent => :destroy
  has_many :image_tags, :dependent => :destroy
  has_many :tags, :through => :image_tags
  has_many :image_likes, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :line_items, :dependent => :destroy
  has_many :orders, :through => :line_items

  # SCOPE
  scope :removed_images, where(:is_removed => true)
  scope :avai_images, where(:is_removed => false)

  scope :flagged, avai_images.joins(
      "LEFT JOIN image_flags ON images.id = image_flags.image_id"
    ).where("image_flags.reported_by IS NOT NULL").readonly(false)

  scope :un_flagged, avai_images.joins(
      "LEFT JOIN image_flags ON images.id = image_flags.image_id"
    ).where("image_flags.reported_by IS NULL").readonly(false)

  scope :joined_images, avai_images.joins(
      "JOIN galleries AS gals ON gals.id = images.gallery_id"
    ).joins("LEFT JOIN image_flags ON images.id = image_flags.image_id").readonly(false)

  scope :public_images, joined_images.joins("JOIN users ON gals.user_id = users.id").where(
    "gals.permission = :gallery_permission
    AND image_flags.reported_by IS NULL
    AND users.is_banned = :user_banned
    AND users.is_removed = :user_removed",
    { :gallery_permission => Gallery::PUBLIC_PERMISSION,
      :user_banned => false,
      :user_removed => false
    })

  scope :belongs_to_avai_user, joined_images.joins('LEFT JOIN users ON gals.user_id=users.id'
    ).where('users.is_banned = ?', false).readonly(false)

  scope :promoted_images, where("promote_num > ?", 0)

  # Paperclip
  has_attached_file :data,
    :styles => { :smallest => '66x66#', :smaller => '67x67#', :small => '68x68#', :spotlight_small => '74x74#',
      :thumb => '155x155#', :spotlight_thumb => '174x154#', :profile_thumb => '101x101#',
      :medium => '640x640>', :large => '1000x1000>' },
    :storage => :s3,
    :s3_credentials => "#{Rails.root}/config/amazon_s3.yml",
    :path => "image/:id/:style.:extension",
    :default_url => "/assets/image-default-:style.jpg"

  validates_attachment :data, :presence => true,
    :size => { :in => 0..10.megabytes, :message => 'File size cannot exceed 10MB' },
    :content_type => { :content_type => [ 'image/jpeg','image/jpg','image/png',"image/gif"],
      :message => 'File type must be one of [.jpeg, .jpg, .png, .gif]' }

  # CALLBACK
  before_create :set_default_tier
  after_create :save_image_dimensions, :process_filename
  after_initialize :init_random_price, :init_tier

  SALE_REPORT_TYPE = {
    :quantity => "quantity",
    :price => "price"
  }
  PRINTED_SIZES = {
    :square => IMAGE_SQUARE_PRINTED_SIZES,
    :rectangular => IMAGE_PORTRAIT_PRINTED_SIZES
  }
  TIERS = { :tier_1 => '1', :tier_2 => '2', :tier_3 => '3' }
  TIERS_PRICES = {
    TIERS[:tier_1] => TIER_1_PRICES,
    TIERS[:tier_2] => TIER_2_PRICES,
    TIERS[:tier_3] => TIER_3_PRICES
  }

  # CLASS METHODS
  class << self
    def do_search(params = {})
      params[:filtered_params][:sort_field] = 'name' unless params[:filtered_params].has_key?("sort_field")
      paging_info = parse_paging_options(params[:filtered_params], {:sort_mode => :extended})

      sphinx_search_options = params[:sphinx_search_options]
      sphinx_search_options = {} if sphinx_search_options.blank?

      sphinx_search_options.merge!({
        :star => true,
        :page => paging_info.page_id,
        :per_page => paging_info.page_size
      })

      self.search(
        SharedMethods::Converter::SearchStringConverter.process_special_chars(params[:query]),
        sphinx_search_options)
    end

    # Search within public images only
    def do_search_public_images(params = {})
      params[:sphinx_search_options] = {:index => "public_images"}
      self.do_search(params)
    end
    
    def get_browse_images params
      conditions = [
        "gals.permission = :gallery_permission
        AND image_flags.reported_by IS NULL
        AND users.is_banned = :user_banned
        AND users.is_removed = :user_removed",
        { :gallery_permission => Gallery::PUBLIC_PERMISSION,
          :image_removed => false,
          :user_banned => false,
          :user_removed => false
        }
      ]
      paging_info = parse_paging_options(params,
        {:sort_criteria => "images.updated_at DESC"})

      self.joined_images.joins("JOIN users ON gals.user_id = users.id").where(conditions).paginate(
        :page => paging_info.page_id,
        :per_page => paging_info.page_size,
        :order => paging_info.sort_string)
    end
    
    def get_spotlight_images params
      conditions = [
        "gals.permission = :gallery_permission
        AND image_flags.reported_by IS NULL
        AND users.is_banned = :user_banned
        AND users.is_removed = :user_removed
        AND images.promote_num > 0",
        { :gallery_permission => Gallery::PUBLIC_PERMISSION,
          :image_removed => false,
          :user_banned => false,
          :user_removed => false
        }
      ]
      paging_info = parse_paging_options(params,
        {:sort_criteria => "images.promote_num DESC, images.updated_at DESC"})

      self.joined_images.joins("JOIN users ON gals.user_id = users.id").where(conditions).paginate(
        :page => paging_info.page_id,
        :per_page => paging_info.page_size,
        :order => paging_info.sort_string)
    end

    def get_all_images_with_current_user(params, current_user = nil)
      if current_user.blank?
        conditions = [
          "gals.permission = :gallery_permission
          AND image_flags.reported_by IS NULL
          AND users.is_banned = :user_banned
          AND users.is_removed = :user_removed",
          { :gallery_permission => Gallery::PUBLIC_PERMISSION,
            :image_removed => false,
            :user_banned => false,
            :user_removed => false
          }
        ]
        
        
      else
        conditions = [
          "gals.permission = :gallery_permission
          AND (gals.user_id = :user_id OR image_flags.reported_by IS NULL)
          AND users.is_banned = :user_banned
          AND users.is_removed = :user_removed",
          { :gallery_permission => Gallery::PUBLIC_PERMISSION,
            :user_id => current_user.id,
            :image_removed => false,
            :user_banned => false,
            :user_removed => false
          }
        ]
      end

      paging_info = parse_paging_options(params,
        {:sort_criteria => "images.promote_num DESC, images.updated_at DESC, images.likes DESC"})

      self.joined_images.joins("JOIN users ON gals.user_id = users.id").where(conditions).paginate(
        :page => paging_info.page_id,
        :per_page => paging_info.page_size,
        :order => paging_info.sort_string)
    end

    def load_images(params = {})
      default_filter_logic = lambda do
        paging_info = parse_paging_options(params)
        self.includes(:gallery).paginate(
          :page => paging_info.page_id,
          :per_page => paging_info.page_size,
          :order => paging_info.sort_string)
      end

      case params[:sort_field]
        when 'date_uploaded' then
          params[:sort_field] = "images.created_at"
          default_filter_logic.call
        when 'num_of_views' then
          params[:sort_field] = "images.pageview"
          default_filter_logic.call
        when 'num_of_orders' then
          self.load_images_with_orders_count(params)
        when 'num_of_likes' then
          params[:sort_field] = "images.likes"
          default_filter_logic.call
        else
          default_filter_logic.call
        end
    end

    def load_images_with_orders_count(params = {})
      params[:sort_field] = "orders_count"
      paging_info = parse_paging_options(params)
      self.includes(:gallery).joins(%Q{
        LEFT JOIN (
          SELECT image_id, COUNT(order_id) AS orders_count
          FROM line_items GROUP BY image_id
        ) orders_data ON images.id = orders_data.image_id
      }).select("DISTINCT images.*, COALESCE(orders_data.orders_count, 0) AS orders_count").paginate(
        :page => paging_info.page_id,
        :per_page => paging_info.page_size,
        :order => paging_info.sort_string)
    end

    def load_popular_images(params = {}, current_user = nil)
      paging_info = parse_paging_options(params,
        {:sort_criteria => "images.promote_num DESC, images.updated_at DESC, images.likes DESC"})
      # TODO: calculate the popularity of the images: base on how many times an image is "liked".
      self.includes(:gallery).joins([:gallery]).
        where("galleries.permission = ?", Gallery::PUBLIC_PERMISSION).paginate(
          :page => paging_info.page_id,
          :per_page => paging_info.page_size,
          :order => paging_info.sort_string)
    end

    def exposed_methods
      [ :image_url, :image_thumb_url, :username, :creation_timestamp, :user_fullname,
        :public_link, :user_id, :user_avatar, :comments_number]
    end

    def exposed_attributes
      [:id, :name, :description, :data_file_name, :gallery_id, :price, :likes, :keyword]
    end

    def exposed_associations
      []
    end

    # protected

    def parse_paging_options(options, default_opts = {})
      if default_opts.blank?
        default_opts = {
          :sort_criteria => "images.created_at DESC"
        }
      end
      paging_options(options, default_opts)
    end
  end

  # INSTANCE METHODS
  def get_price(tier, size)
    TIERS_PRICES[tier][size]
  end

  def square?
    ratio = self.width*1.0 / self.height
    (1.0/RECTANGULAR_RATIO < ratio) && (ratio < RECTANGULAR_RATIO)
  end

  def get_square_sizes
    result = []
    edge = [self.width, self.height].min
    max_size = edge / PRINTER_RESOLUTION
    PRINTED_SIZES[:square].each { |size| result << size if size.slice(0).to_i <= max_size }

    # need check image size, temporarily
    result << PRINTED_SIZES[:square][0] if result.count==0
    return result
  end

  def get_rectangular_sizes
    result = []
    short_edge = [self.width, self.height].min
    long_edge = [self.width, self.height].max
    max_short_edge = short_edge / PRINTER_RESOLUTION
    max_long_edge = long_edge / PRINTER_RESOLUTION

    PRINTED_SIZES[:rectangular].each { |size|
      edges = size.split('x')
      result << size if edges[0].to_i <= max_short_edge && edges[1].to_i <= max_long_edge
    }

    # need check image size, temporarily
    result << PRINTED_SIZES[:rectangular][0] if result.count==0
    return result
  end

  def printed_sizes
    if self.square?
      self.get_square_sizes
    else
      self.get_rectangular_sizes
    end
  end

  def comments_number
    self.comments.count
  end

  def set_as_album_cover
    self.update_attribute('is_gallery_cover', true)
    Image.update_all 'is_gallery_cover=false', "gallery_id = #{ self.gallery_id } and id <> #{ self.id }"
  end

  def set_as_owner_avatar
    self.update_attribute('is_owner_avatar', true)
    Image.update_all 'is_owner_avatar=false', "gallery_id in (#{ self.author.galleries.collect(&:id).join(',') }) and id <> #{ self.id }"
    profile_img = ProfileImage.first :conditions => {:user_id => self.author.id, :link_to_image => self.id}
    if profile_img.nil?
      ProfileImage.create({ :user_id => self.author.id,
                            :link_to_image => self.id,
                            :data => open(self.data.url(:thumb)),
                            :last_used => Time.now })
    else
      profile_img.set_as_default
    end
  end

  def is_flagged?
    ImageFlag.exists?(:image_id => self.id)
  end

  def flag(user, params={}, result = {})
    if (self.author.is_banned)
      result = { :success => false, :msg => "The author is already banned." }
    else
      if (self.image_flags.count > 0)
        result = { :success => false, :msg => "The image is already flagged." }
      else
        if (self.has_owner(user.id))
         return result = { :success => false, :msg => "You can not flag your own image" }
        end
        description = ImageFlag.process_description(params[:type].to_i, params[:desc])
        if description.nil?
          if params[:type].to_i == ImageFlag::FLAG_TYPE['copyright']
            msg = 'Copyright flag must have photo\'s owner information'
          else
            msg = 'Terms of Use Violation flag must have reason reporting'
          end
          result = { :success => false, :msg => msg }
        else
          flag = ImageFlag.new({ :image_id => self.id, :reported_by => user.id,
            :flag_type => params[:type].to_i, :description => description })
          if flag.save
            # Remove all images in shopping carts
            line_items = LineItem.joins(:order).joins(:image).where(
              :images => {:id => self.id},
              :orders => {:status => Order::STATUS[:shopping]}
            )
            
            line_items.each do |line_item|
              line_item.update_attributes {:quantity => 0}
            end

            if self.author.will_be_banned?
              # Ban the image's author.
              self.author.update_attribute(:is_banned, true)
              # Send email.
              UserMailer.user_is_banned(self.author).deliver
            else
              # Send email about the flagged image.
              UserMailer.image_is_flagged(self.author, self).deliver
            end

            # Update result
            result = { :success => true }
          else
            result = { :success => false, :msg => flag.errors.full_messages[0]}
          end
        end
      end
    end
    return result
  end

  def reinstate
    self.image_flags.destroy_all
    self.update_attribute(:is_removed, false)
  end

  def has_owner(id)
    self.gallery.user.id == id
  end

  def username
    user = author
    if user
      return user.username
    end
  end

  def user_avatar
    user = author
    if user
      return user.avatar_url(:large)
    end
  end

  def user_fullname
    user = author
    if user
      return user.fullname
    end
  end

  def user_id
    user = author
    if user
      return user.id
    end
  end

  def image_url
    data.url(:medium)
  end

  def image_thumb_url
    data.url(:thumb)
  end

  def creation_timestamp
    ::Util.distance_of_time_in_words_to_now(self.created_at)
  end

  # public link on social network
  def public_link
    url_for :controller => 'images', :action => 'public', :id => self.id, :only_path => false, :host => DOMAIN
  end

  # Shortcut to get image's URL
  def url(options = nil)
    self.data.url(options)
  end

  def liked_by_user(user_id)
    result = {:success => false}
    Image.transaction do
      if !User.exists? user_id
        result[:msg] = "User does not exist anymore"
      elsif ImageLike.exists?({:image_id => self.id, :user_id => user_id})
        result[:msg] = "This image has been liked"
      else
        img_like = ImageLike.new({:image_id => self.id, :user_id => user_id})
        self.image_likes << img_like
        self.likes += 1
        self.save
        result[:likes] = self.likes
        result[:success] = true
      end
    end
    return result
  end

  def disliked_by_user(user_id)
    result = {:success => false}
    Image.transaction do
      if !User.exists? user_id
        result[:msg] = "User does not exist anymore"
      elsif !ImageLike.exists?({:image_id => self.id, :user_id => user_id})
        result[:msg] = "This image has been unliked"
      else
        img_like = ImageLike.find_by_image_id self.id, :conditions => {:user_id => user_id}
        img_like.destroy
        self.likes -= 1
        self.save
        result[:likes] = self.likes
        result[:success] = true
      end
    end
    return result
  end

  def liked_by?(user_id)
    ImageLike.exists?({:image_id => self.id, :user_id => user_id})
  end

  def total_sales(mon = nil) # mon with year, return saled $$
    total = 0

    if mon.blank?
      orders = self.orders.where({:transaction_status => Order::TRANSACTION_STATUS[:complete]})
    else
      start_date = DateTime.parse("01 #{mon}")
      end_date = TimeCalculator.last_day_of_month(start_date.mon, start_date.year).end_of_day
      end_date = end_date.strftime("%Y-%m-%d %T")
      start_date = start_date.strftime("%Y-%m-%d %T")
      orders = self.orders.where "transaction_status ='#{Order::TRANSACTION_STATUS[:complete]}'
        and transaction_date > '#{start_date.to_s}' and transaction_date < '#{end_date.to_s}'"
    end

    orders_in = orders.collect &:id
    saled_items = (orders.length==0) ? [] : self.line_items.where("order_id in (#{orders_in.join(',')})")
    saled_items.each { |item| total += (item.price + item.tax)*item.quantity }
    return total
  end

  # mon with year, return saled quantity
  def saled_quantity(mon = nil)
    result = 0

    if mon.nil?
      orders = self.orders.where({:transaction_status => Order::TRANSACTION_STATUS[:complete]})
    else
      start_date = DateTime.parse("01 #{mon}")
      end_date = TimeCalculator.last_day_of_month(start_date.mon, start_date.year).strftime("%Y-%m-%d %T")
      start_date = start_date.strftime("%Y-%m-%d %T")
      orders = self.orders.where "transaction_status ='#{Order::TRANSACTION_STATUS[:complete]}' and transaction_date > '#{start_date.to_s}' and transaction_date < '#{end_date.to_s}'"
    end

    orders_in = orders.collect { |o| o.id }
    saled_items = (orders.length==0) ? [] : self.line_items.where("order_id in (#{orders_in.join(',')})")
    saled_items.each { |item| result += item.quantity }
    return result
  end

  def raw_purchased_info(item_paging_params = {})
    result = {:data => [], :total => 0}
    orders = self.orders.where({:transaction_status => Order::TRANSACTION_STATUS[:complete]}).collect { |o| o.id }
    saled_items = []
    if orders.length > 0
      paging_info = LineItem.paging_options(item_paging_params)
      saled_items = LineItem.paginate(
        :page => paging_info.page_id,
        :per_page => paging_info.page_size,
        :joins => "LEFT JOIN orders ON orders.id = line_items.order_id LEFT JOIN users ON users.id = orders.user_id",
        :select => "line_items.*, users.id as purchaser_id, orders.transaction_date as purchased_date",
        :order => "purchased_date DESC",
        :conditions => ["image_id=? and order_id in (#{orders.join(',')})", self.id]
      )
    end

    return saled_items
  end

  def get_purchased_info(item_paging_params = {})
    result = {:data => [], :total_quantity => 0, :total_sale => 0}
    orders = self.orders.where({:transaction_status => Order::TRANSACTION_STATUS[:complete]}).collect { |o| o.id }
    if orders.length > 0
      paging_info = LineItem.paging_options(item_paging_params)
      saled_items = LineItem.paginate(
        :page => paging_info.page_id,
        :per_page => paging_info.page_size,
        :joins => "LEFT JOIN orders ON orders.id = line_items.order_id LEFT JOIN users ON users.id = orders.user_id",
        :select => "line_items.*, users.id as purchaser_id, orders.transaction_date as purchased_date",
        :order => "purchased_date DESC",
        :conditions => ["image_id=? and order_id in (#{orders.join(',')})", self.id]
      )

      saled_items.each { |item|
        user = User.find_by_id item.purchaser_id
        purchased_date = DateTime.parse(item.purchased_date).strftime "%B %d, %Y"
        result[:data] << {
          :username => user.username,
          :plexi_mount => item.plexi_mount ? 'Plexi Mount' : 'No Plexi Mount',
          :size => item.size,
          :quantity => item.quantity,
          :moulding => item.moulding,
          :date => purchased_date,
          :avatar_url => user.avatar_url,
          :user_id => user.id
        }
        result[:total_quantity] += item.quantity
        result[:total_sale] += item.quantity * (item.tax + item.price)
      }
    end

    return result
  end

  # return saled quantity
  def get_monthly_sales_over_year(current_date, options = {:report_by => SALE_REPORT_TYPE[:price]})
    result = []
    date = DateTime.parse current_date.to_s
    prior_months = TimeCalculator.prior_year_period(date, {:format => '%b %Y'})
    prior_months.each { |mon|
      short_mon = DateTime.parse(mon).strftime('%b')
      if options.nil?
        result << { :month => short_mon, :sales => self.total_sales(mon) }
      elsif options.has_key?(:report_by)
        result << {
          :month => short_mon,
          :sales => (options[:report_by]==SALE_REPORT_TYPE[:price]) ? self.total_sales(mon) : self.saled_quantity(mon)
        }
      end
    }
    return result
  end

  def set_album_cover
    if Image.exists?({:gallery_id => self.gallery_id, :is_gallery_cover => true})
      self.is_gallery_cover = false
    else
      self.is_gallery_cover = true
    end
  end

  # Increase the pageview counter
  def increase_pageview
    self.class.increment_counter(:pageview, self.id)
  end

  def orders_count
    if !self.attributes.has_key?('orders_count')
      self.attributes['orders_count'] = self.orders.count
    else
      self.attributes['orders_count'].to_i
    end
  end

  def promote
    self.update_attribute(:promote_num, 1)
  end

  def demote
    self.update_attribute(:promote_num, 0)
  end

  def is_promoted?
    (self.promote_num.to_i > 0)
  end
  alias_method :is_promoted, :is_promoted?

  protected
    def set_default_tier
      self.tier = TIERS[:tier_1]
    end

    def process_filename
      reg = /(.jpeg|.jpg|.png|.gif)$/i
      self.update_attribute(:name, self.name.gsub(reg, '')) if self.name =~ reg
    end

    # Detect the image dimensions.
    def save_image_dimensions
      file = self.data.queued_for_write[:original]
      if file.blank?
        file = data.url(:original)
      end

      geo = Paperclip::Geometry.from_file(file)
      self.update_attribute(:width, geo.width)
      self.update_attribute(:height, geo.height)
    end


    # TODO: this method is for test only. Please REMOVE this in production mode.
    def init_random_price
      if self.price.blank?
        self.price = rand(50)
      end
    end

    def init_tier
      if self.tier.blank?
        self.tier = TIERS[0]
      end
    end

    #indexing with thinking sphinx
    define_index do
      indexes name
      indexes description
      indexes keyword
      indexes author(:username), :as => :author, :sortable => true

      has gallery_id

      set_property :field_weights => {
        :name => 7,
        :keyword => 3,
        :author => 2,
        :description => 1
      }

      if Rails.env.production?
        set_property :delta => FlyingSphinx::DelayedDelta
      else
        set_property :delta => true
      end
    end

    # Index for public images
    define_index :public_images do
      indexes name
      indexes description
      indexes keyword
      indexes is_removed
      indexes author(:username), :as => :author, :sortable => true

      has gallery_id

      set_property :field_weights => {
        :name => 7,
        :keyword => 3,
        :author => 2,
        :description => 1
      }

      where("images.id IN (SELECT id FROM (#{Image.public_images.to_sql}) public_images)")

      if Rails.env.production?
        set_property :delta => FlyingSphinx::DelayedDelta
      else
        set_property :delta => true
      end
    end
end
