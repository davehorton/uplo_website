class Image < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include ::SharedMethods::Paging
  include ::SharedMethods::SerializationConfig
  include ::SharedMethods::Converter
  include ::SharedMethods

  SEARCH_TYPE = 'images'
  SORT_OPTIONS = { :spotlight => 'spotlight', :view => 'views', :recent => 'recent'}
  SORT_CRITERIA = {
    SORT_OPTIONS[:view] => 'pageview DESC',
    SORT_OPTIONS[:recent] => 'created_at DESC',
    SORT_OPTIONS[:spotlight] => 'promote_num DESC'
  }
  FILTER_OPTIONS = ['date_uploaded', 'num_of_views', 'num_of_sales', 'num_of_likes']
  SALE_REPORT_TYPE = {
    :quantity => "quantity",
    :price => "price"
  }
  PRINTED_SIZES = {
    :square => IMAGE_SQUARE_PRINTED_SIZES,
    :rectangular => IMAGE_PORTRAIT_PRINTED_SIZES
  }
  TIERS = GlobalConstant::TIERS
  TIERS_PRICES = {
    TIERS[:tier_1] => TIER_1_PRICES,
    TIERS[:tier_2] => TIER_2_PRICES,
    TIERS[:tier_3] => TIER_3_PRICES
  }
  MOULDING = GlobalConstant::MOULDING
  PENDING_MOULDING = {
    MOULDING[:print] => false,
    MOULDING[:print_luster] => false,
    MOULDING[:canvas] => false,
    MOULDING[:plexi] => false,
    MOULDING[:black] => true,
    MOULDING[:white] => true,
    MOULDING[:light_wood] => true,
    MOULDING[:rustic_wood] => true
  }
  MOULDING_SIZES_CONSTRAIN = {
    MOULDING[:rustic_wood] => [IMAGE_SQUARE_PRINTED_SIZES[0], IMAGE_PORTRAIT_PRINTED_SIZES[0]]
  }
  # TODO: temp reset to 0, plz check with iOS & remove, also see: users api: get_moulding
  MOULDING_DISCOUNT = {
    MOULDING[:print] => 0,
    MOULDING[:print_luster] => 0,
    MOULDING[:canvas] => 0,
    MOULDING[:plexi] => 0,
    MOULDING[:black] => 0,
    MOULDING[:white] => 0,
    MOULDING[:light_wood] => 0,
    MOULDING[:rustic_wood] => 0
  }
  MOULDING_PRICES = {
    MOULDING[:print] => GlobalConstant::MOULDING_PRICES[MOULDING[:print]],
    MOULDING[:print_luster] => GlobalConstant::MOULDING_PRICES[MOULDING[:print]],
    MOULDING[:canvas] => GlobalConstant::MOULDING_PRICES[MOULDING[:canvas]],
    MOULDING[:plexi] => GlobalConstant::MOULDING_PRICES[MOULDING[:plexi]],
    MOULDING[:black] => nil,
    MOULDING[:white] => nil,
    MOULDING[:light_wood] => nil,
    MOULDING[:rustic_wood] => nil
  }
  DEFAULT_STYLES = { :smallest => '66x66#', :smaller => '67x67#', :small => '68x68#', :spotlight_small => '74x74#', :thumb => '155x155#', :spotlight_thumb => '174x154#', :profile_thumb => '101x101#', :medium => '640x640>' }

  # ASSOCIATIONS
  belongs_to :gallery, :touch => true
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
  scope :avai_images, joins(self.sanitize_sql([
      "JOIN galleries AS g ON g.id = images.gallery_id
      JOIN users as u ON g.user_id = u.id AND u.is_removed = ?", false
    ])).where("images.is_removed = ?", false)

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

  scope :belongs_to_avai_user, joined_images.joins('LEFT JOIN users AS avai_users ON gals.user_id=avai_users.id'
    ).where('avai_users.is_banned = ?', false).readonly(false)

  scope :promoted_images, where("promote_num > ?", 0)

  # Paperclip
  has_attached_file :data,
    :styles => lambda { |attachment| attachment.instance.available_styles || {}},
    :storage => :s3,
    :s3_credentials => "#{Rails.root}/config/amazon_s3.yml",
    :path => "image/:id/:style.:extension",
    :default_url => "/assets/image-default-:style.jpg"

  validates_attachment :data, :presence => true,
    :size => { :in => 0..10.megabytes, :message => 'File size cannot exceed 10MB' },
    :content_type => { :content_type => [ 'image/jpeg','image/jpg'],
      :message => 'File type must be one of [.jpeg, .jpg]' }

  # CALLBACK
  before_post_process :init_image_info
  before_create :init_tier
  after_initialize :init_random_price, :init_tier

  # CLASS METHODS
  class << self
    # Search within public images only
    def do_search_public_images(params = {})
      params[:sphinx_search_options] = {:index => "public_images"}
      self.do_search(params)
    end

    # Search within public images & private of user
    def do_search_accessible_images(user_id, params)
      params ||= {}
      with_display = "*, IF(author_id = #{user_id} OR permission = #{Gallery::PUBLIC_PERMISSION}, 1, 0) AS display"
      params[:sphinx_search_options] = {
        :joins => '
          LEFT JOIN galleries AS gals ON gals.id = images.gallery_id
          LEFT JOIN image_flags ON images.id = image_flags.image_id
          LEFT JOIN users ON gals.user_id = users.id',
        :sphinx_select => with_display,
        :with => {
          :banned_user => false,
          :removed_user => false,
          :flagged_by => '',
          :display => 1 }
      }
      self.do_search(params)
    end

    def get_spotlight_images(user_id, params)
      params ||= {}
      with_display = "*, IF(author_id = #{user_id} OR permission = #{Gallery::PUBLIC_PERMISSION}, 1, 0) AS display"
      params[:sphinx_search_options] = {
        :joins => '
          LEFT JOIN galleries AS gals ON gals.id = images.gallery_id
          LEFT JOIN image_flags ON images.id = image_flags.image_id
          LEFT JOIN users ON gals.user_id = users.id',
        :sphinx_select => with_display,
        :with => {
          :banned_user => false,
          :removed_user => false,
          :flagged_by => '',
          :display => 1,
          :promote_num => 1 }
      }
      self.do_search(params)
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
        when 'num_of_sales' then
          self.load_images_with_sales_count(params)
        when 'num_of_likes' then
          params[:sort_field] = "images.likes"
          default_filter_logic.call
        else
          default_filter_logic.call
        end
    end

    def load_images_with_sales_count(params = {})
      params.delete(:sort_field)
      sort_direction = params[:sort_direction] || 'ASC'

      paging_info = parse_paging_options(params, {
        :sort_criteria => {
          :sales_count => sort_direction,
          :sales_value => sort_direction
        }
      })

      self.includes(:gallery).joins(self.sanitize_sql([
        "LEFT JOIN (
          SELECT line_items.image_id,
            SUM(line_items.quantity) AS sales_count,
            SUM(line_items.quantity * (line_items.tax + line_items.price)) AS sales_value
          FROM line_items JOIN orders
          ON line_items.order_id = orders.id AND orders.transaction_status = ?
          GROUP BY line_items.image_id
        ) orders_data ON images.id = orders_data.image_id",
        Order::TRANSACTION_STATUS[:complete]
      ])).select("DISTINCT images.*,
        COALESCE(orders_data.sales_count, 0) AS sales_count,
        COALESCE(orders_data.sales_value, 0) AS sales_value"
      ).paginate(
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
      [:image_url, :image_thumb_url, :username, :creation_timestamp, :user_fullname,
        :public_link, :user_id, :user_avatar, :comments_number, :gallery_name]
    end

    def exposed_attributes
      [:id, :name, :description, :data_file_name, :name, :gallery_id, :price, :likes, :keyword,
        :is_owner_avatar, :is_gallery_cover, :tier]
    end

    def exposed_associations
      []
    end

    def parse_paging_options(options, default_opts = {})
      if default_opts.blank?
        default_opts = {
          :sort_criteria => "images.created_at DESC"
        }
      end
      paging_options(options, default_opts)
    end

    protected
      def do_search(params = {})
        params[:filtered_params][:sort_field] = 'name' unless params[:filtered_params].has_key?(:sort_field)

        default_opt = {}
        paging_info = parse_paging_options(params[:filtered_params], {:sort_mode => :extended})

        sphinx_search_options = params[:sphinx_search_options]
        sphinx_search_options = {} if sphinx_search_options.blank?
        sphinx_search_options[:index] = 'general_images' if sphinx_search_options[:index].blank?

        sphinx_search_options.merge!({
          :star => true,
          :retry_stale => true,
          :page => paging_info.page_id,
          :per_page => paging_info.page_size,
          :order => paging_info.sort_string
        })

        search_term = SharedMethods::Converter::SearchStringConverter.process_special_chars(params[:query])
        Image.search(search_term, sphinx_search_options)
      end
  end

  # INSTANCE METHODS
  def get_price(moulding, size)
    return MOULDING_PRICES[moulding][self.tier][size]
  end

  def square?
    ratio = self.width*1.0 / self.height
    (1.0/RECTANGULAR_RATIO < ratio) && (ratio < RECTANGULAR_RATIO)
  end

  def valid_for_size?(size)
    if self.square?
      edge = [self.width, self.height].min
      (edge / PRINT_RESOLUTION) >= size.split('x')[0].strip.to_i
    else
      edges = size.split('x')
      short_edge = [self.width, self.height].min
      long_edge = [self.width, self.height].max
      (short_edge / PRINT_RESOLUTION) >= edges[0].strip.to_i && (long_edge / PRINT_RESOLUTION) >= edges[1].strip.to_i
    end
  end

  def printed_sizes
    result = []
    if self.square?
      sizes = PRINTED_SIZES[:square]
    else
      sizes = PRINTED_SIZES[:rectangular]
    end
    sizes.each { |size|
      result << size if self.valid_for_size?(size)
    }
    return result
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
              :images => {:id => self.id}
            ).where("status = '#{Order::STATUS[:shopping]}' OR status = '#{Order::STATUS[:checkout]}'").readonly(false)
            self.transaction do
              line_items.each do |line_item|
                line_item.update_attribute(:quantity, 0)
              end
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

  # THIS METHOD IS USED TO SHOW THE TOTAL SALE FOR USER.
  # The rule: User receives a half of total sale. Need to find something else for this. Reporting...
  def user_total_sales(mon = nil)
    total = 0
    if mon == nil
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
    saled_items.each { |item| total += (item.price * item.quantity) }

    return total * PAY_RATIO

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
      end_date = TimeCalculator.last_day_of_month(start_date.mon, start_date.year).end_of_day
      end_date = end_date.strftime("%Y-%m-%d %T")
      start_date = start_date.strftime("%Y-%m-%d %T")
      orders = self.orders.where "transaction_status ='#{Order::TRANSACTION_STATUS[:complete]}'
        and transaction_date > '#{start_date.to_s}' and transaction_date < '#{end_date.to_s}'"
    end

    orders_in = orders.collect &:id
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
    orders = self.orders.where({:transaction_status => Order::TRANSACTION_STATUS[:complete]}).collect &:id
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
        result[:total_sale] += (item.quantity *  item.price)/2
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
        result << { :month => short_mon, :sales => self.user_total_sales(mon) }
      elsif options.has_key?(:report_by)
        result << {
          :month => short_mon,
          :sales => (options[:report_by]==SALE_REPORT_TYPE[:price]) ? self.user_total_sales(mon) : self.saled_quantity(mon)
        }
      end
    }
    return result
  end

  def gallery_name
    return self.gallery.name
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

  def sales_count
    if !self.attributes.has_key?('sales_count')
      self.attributes['sales_count'] = self.orders.completed_orders.joins(
        :line_items
      ).sum('line_items.quantity').to_i
    else
      self.attributes['sales_count'].to_i
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

#==============================================================================
# Description:
# - get available styles
# - including all DEFAULT_STYLES & printable size (for ordering)
# Note:
#
#==============================================================================
  def available_styles
    result = DEFAULT_STYLES
    self.printed_sizes.each do |size|
      ratios = size.split('x')
      ratios.collect! { |tmp| tmp.strip.to_i }
      if self.square?
        width = height = ratios[0] * PRINT_RESOLUTION
      elsif self.width > self.height
        width = ratios.max * PRINT_RESOLUTION
        height = ratios.min * PRINT_RESOLUTION
      else
        width = ratios.min * PRINT_RESOLUTION
        height = ratios.max * PRINT_RESOLUTION
      end
      result["scale#{size}".to_sym] = "#{width}x#{height}#"
    end
    result
  end

  protected
    # Detect the image dimensions.
    def init_image_info
      file = self.data.queued_for_write[:original]
      if file.blank?
        file = data.url(:original)
      end

      geo = Paperclip::Geometry.from_file(file)
      self.width = geo.width
      self.height = geo.height
      if !self.name.blank?
        self.name = file.original_filename.gsub(/(.jpeg|.jpg)$/i, '') if file.original_filename =~ /(.jpeg|.jpg)$/i
      end
    end


    # TODO: this method is for test only. Please REMOVE this in production mode.
    def init_random_price
      if self.price.blank?
        self.price = rand(50)
      end
    end

    def init_tier
      if self.tier.blank?
        self.tier = TIERS[:tier_1]
      end
    end

    #indexing with thinking sphinx
    define_index :general_images do
      # fields
      indexes name, :sortable => true
      indexes description
      indexes keyword
      indexes gallery(:name), :as => :album

      # attributes
      has gallery_id, created_at, pageview, promote_num, updated_at
      has author(:is_banned), :as => :banned_user
      has author(:is_removed), :as => :removed_user
      has image_flags(:reported_by), :as => :flagged_by
      has author(:id), :as => :author_id
      has gallery(:permission), :as => :permission

      # weight
      set_property :field_weights => {
        :name => 15,
        :keyword => 7,
        :description => 3,
        :author => 1,
        :album => 1
      }

      if Rails.env.production?
        set_property :delta => FlyingSphinx::DelayedDelta
      else
        set_property :delta => true
      end
    end

    # Index for public images
    define_index :public_images do
      # fields
      indexes name, :sortable => true
      indexes keyword
      indexes author(:username), :as => :author, :sortable => true

      # attributes
      has gallery_id, created_at, pageview, promote_num

      # weight
      set_property :field_weights => {
        :name => 7,
        :keyword => 3,
        :author => 1
      }

      where("images.id IN (SELECT id FROM (#{Image.public_images.to_sql}) public_images)")

      if Rails.env.production?
        set_property :delta => FlyingSphinx::DelayedDelta
      else
        set_property :delta => true
      end
    end
end
