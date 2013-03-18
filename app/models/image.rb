class Image < ActiveRecord::Base
  include ::Shared::QueryMethods
  include ImageConstants

  belongs_to :active_user, class_name: 'User', foreign_key: 'user_id', conditions: { banned: false, removed: false }
  belongs_to :user, counter_cache: true
  belongs_to :gallery,     :touch => true
  belongs_to :public_gallery, class_name: 'Gallery', foreign_key: 'gallery_id', conditions: { permission: Permission::Public.new }

  has_many :comments,      :dependent => :destroy
  has_many :image_flags,   :dependent => :destroy
  has_many :image_likes,   :dependent => :destroy
  has_many :image_tags,    :dependent => :destroy
  has_many :line_items,    :dependent => :destroy
  has_many :orders,        :through => :line_items
  has_many :tags,          :through => :image_tags

  has_attached_file :image,
    styles: lambda { |attachment| attachment.instance.available_styles || {}},
    default_url: "/assets/gallery-thumb.jpg"

  validates_attachment :image, :presence => true,
    :size => { :in => 0..100.megabytes, :message => 'File size cannot exceed 100MB' },
    :content_type => { :content_type => [ 'image/jpeg','image/jpg'],
    :message => 'File type must be one of [.jpeg, .jpg]' }, :on => :create
  validate :validate_quality, :on => :create

  before_create :init_tier
  before_post_process :init_image_info

  default_scope order('created_at desc')
  scope :removed,     where(removed: true)
  scope :not_removed, where(removed: false)

  scope :flagged,     not_removed.joins(:image_flags)
  scope :unflagged,   not_removed.includes(:image_flags).where(image_flags: { id: nil })

  scope :processing,  not_removed.joins(:active_user).where(data_processing: true)
  scope :visible,     not_removed.joins(:active_user).where(data_processing: false)
  scope :visible_everyone, visible.unflagged.joins(:public_gallery)

  scope :with_gallery, includes(:gallery)

  # TODO: replace with pg full text search implementation
  def self.do_search_public_images(params = {})
    #params[:sphinx_search_options] = {:index => "public_images"}
    #self.do_search(params)
  end

  # TODO: replace with pg full text search implementation
  def self.do_search_accessible_images(user_id, params)
=begin
    params ||= {}
    with_display = "*, IF(author_id = #{user_id} OR permission = #{Permission::Public.new}, 1, 0) AS display"
    params[:sphinx_search_options] = {
      :joins => '
        LEFT JOIN galleries AS gals ON gals.id = images.gallery_id
        LEFT JOIN image_flags ON images.id = image_flags.image_id
        LEFT JOIN users ON gals.user_id = users.id',
      :sphinx_select => with_display,
      :with => {
        :data_processing => false,
        :banned_user => false,
        :removed_user => false,
        :flagged_by => '',
        :display => 1 }
    }
    self.do_search(params)
=end
  end

  # TODO: replace with pg full text search implementation
  def self.get_spotlight_images(user_id, params)
=begin
    params ||= {}
    with_display = "*, IF(author_id = #{user_id} OR permission = #{Permission::Public.new}, 1, 0) AS display"
    params[:sphinx_search_options] = {
      :joins => '
        LEFT JOIN galleries AS gals ON gals.id = images.gallery_id
        LEFT JOIN image_flags ON images.id = image_flags.image_id
        LEFT JOIN users ON gals.user_id = users.id',
      :sphinx_select => with_display,
      :with => {
        :data_processing => false,
        :banned_user => false,
        :removed_user => false,
        :flagged_by => '',
        :display => 1,
        :promote_num => 1 }
    }
    self.do_search(params)
=end
  end

  # re-implements Shared::QueryMethods function
  # by replacing search fields before caling super
  def self.paginate_and_sort(params = {})
    image_params = params

    if sort_field = params[:sort_field]
      image_params[:sort_field] = case sort_field
        when 'date_uploaded' then
          'created_at'
        when 'num_of_views' then
          'pageview'
        when 'num_of_likes' then
          'image_likes_count'
        end
    end

    super(image_params)
  end

  def self.popular_with_pagination(params = {})
    #  scope :popular, visible_everyone
    params[:sort_expression] = "images.promote_num desc, images.updated_at desc, images.image_likes_count desc"
    visible_everyone.paginate_and_sort(params)
  end

  # TODO: replace with pg full text search
  def self.do_search(params = {})
=begin
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
      :order => paging_info.sort_string,
    })

    search_term = SharedMethods::Converter::SearchStringConverter.process_special_chars(params[:query])
    Image.search(search_term, sphinx_search_options)
=end
  end

  delegate :username, :to => :user, allow_nil: true
  delegate :id, :fullname, :to => :user, allow_nil: true, prefix: true
  delegate :name, :to => :gallery, prefix: true

  def get_price(moulding, size)
    return MOULDING_PRICES[moulding][self.tier][size]
  end

  def get_commission
    return GlobalConstant::IMAGE_COMMISSIONS[self.tier]
  end

  def square?
    ratio = self.width*1.0 / self.height
    threshold = (1 + (RECTANGULAR_RATIO - 1)/2)

    (1.0/threshold < ratio)
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
    result
  end

  def comments_number
    self.comments.count
  end

  def set_as_album_cover
    self.update_attribute('gallery_cover', true)
    Image.update_all 'gallery_cover=false', "gallery_id = #{ self.gallery_id } and id <> #{ self.id }"
  end

  def set_as_owner_avatar
    self.update_attribute('owner_avatar', true)
    Image.update_all 'owner_avatar=false', "gallery_id in (#{ user.galleries.collect(&:id).join(',') }) and id <> #{ self.id }"
    profile_img = ProfileImage.first :conditions => {:user_id => user_id, :link_to_image => self.id}
    if profile_img.nil?
      ProfileImage.create({ :user_id => user_id,
                            :link_to_image => self.id,
                            :avatar => open(self.url(:thumb)),
                            :last_used => Time.now })
    else
      profile_img.set_as_default
    end
  end

  def flagged?
    image_flags.any?
  end

  def flag(user, params={}, result = {})
    if user.banned?
      result = { :success => false, :msg => "The author is already banned." }
    else
      if (self.image_flags.count > 0)
        result = { :success => false, :msg => "The image is already flagged." }
      else
        if user.owns_image?(self)
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

            if user.will_be_banned?
              # Ban the image's author.
              user.update_attribute(:banned, true)
              # Send email.
              UserMailer.banned_user_email(user).deliver
            else
              # Send email about the flagged image.
              UserMailer.flagged_image_email(user, self).deliver
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
    self.update_attribute(:removed, false)
  end

  def creation_timestamp
    ::Util.distance_of_time_in_words_to_now(self.created_at)
  end

  def url(options = nil)
    if data_processing
      "/assets/gallery-thumb.jpg"
    else
      self.image.expiring_url(s3_expire_time, options)
    end
  end

  def image_url
    url(:medium)
  end

  def image_thumb_url
    url(:thumb)
  end

  def user_avatar
    user.try(:avatar_url, :large)
  end

  def liked_by?(user)
    ImageLike.exists?(image_id: id, user_id: user.id)
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
    saled_items.each do |item|
      total += ((item.price * item.quantity) * item.commission_percent)
    end

    return total
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
    order_ids = orders.complete.map(&:id)

    sold_items = []

    if order_ids.any?
      sold_items = LineItem.paginate_and_sort(item_paging_params.merge(sort_expression: 'purchased_date desc')).
        joins("LEFT JOIN orders ON orders.id = line_items.order_id LEFT JOIN users ON users.id = orders.user_id").
        select("line_items.*, users.id as purchaser_id, orders.transaction_date as purchased_date").
        where(["image_id=? and order_id in (#{order_ids.join(',')})", id])
    end

    sold_items
  end

  def get_purchased_info(item_paging_params = {})
    result = {:data => [], :total_quantity => 0, :total_sale => 0}
    order_ids = self.orders.complete.map(&:id)

    if order_ids.any?
      sold_items = LineItem.paginate(item_paging_params.merge(sort_expression: 'purchased_date desc')).
        joins("LEFT JOIN orders ON orders.id = line_items.order_id LEFT JOIN users ON users.id = orders.user_id").
        select("line_items.*, users.id as purchaser_id, orders.transaction_date as purchased_date").
        where(["image_id=? and order_id in (#{order_ids.join(',')})", id])

      sold_items.each { |item|
        user = User.find_by_id(item.purchaser_id)
        purchased_date = DateTime.parse(item.purchased_date).strftime "%B %d, %Y"
        result[:data] << {
          :username => user.try(:username) || 'Deleted',
          :plexi_mount => item.plexi_mount ? 'Plexi Mount' : 'No Plexi Mount',
          :size => item.size,
          :quantity => item.quantity,
          :moulding => item.moulding,
          :date => purchased_date,
          :avatar_url => user.avatar_url,
          :user_id => user.try(:id)
        }
        result[:total_quantity] += item.quantity
        result[:total_sale] += (item.quantity *  item.price)/2
      }
    end

    result
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

  def set_album_cover
    self.gallery_cover = !Image.exists?({:gallery_id => self.gallery_id, :gallery_cover => true})
  end

  # Increase the pageview counter
  def increase_pageview
    self.class.increment_counter(:pageview, self.id)
  end

  def sales_count
    if !self.attributes.has_key?('sales_count')
      self.attributes['sales_count'] = self.orders.completed.joins(:line_items).sum('line_items.quantity').to_i
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

  def promoted?
    (self.promote_num.to_i > 0)
  end
  alias_method :promoted, :promoted?

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
      tmp_width = 0
      tmp_height = 0
      if self.square?
        tmp_width = height = ratios[0] * PRINT_RESOLUTION
      elsif self.width > self.height
        tmp_width = ratios.max * PRINT_RESOLUTION
        tmp_height = ratios.min * PRINT_RESOLUTION
      else
        tmp_width = ratios.min * PRINT_RESOLUTION
        tmp_height = ratios.max * PRINT_RESOLUTION
      end
      result["scale#{size}".to_sym] = "#{tmp_width}x#{tmp_height}#"
      ratio = tmp_width/640.to_f
      ratio = 1 if ratio < 1
      preview_width = tmp_width / ratio
      preview_height = tmp_height / ratio
      result["scale_preview#{size}".to_sym] = "#{preview_width.to_i}x#{preview_height.to_i}#"
    end
    result
  end

  def save_dimensions
    file = self.image.queued_for_write[:original]
    if file.blank?
      file = image.expiring_url(:original)
    end

    geo = Paperclip::Geometry.from_file(file)
    self.width = geo.width
    self.height = geo.height
  end

  protected

    def s3_expire_time
      Time.zone.now.beginning_of_day.since 25.hours
    end

    def validate_quality
      save_dimensions
      min_size = self.square? ? Image::PRINTED_SIZES[:square][0] : Image::PRINTED_SIZES[:rectangular][0]
      if !self.valid_for_size?(min_size)
        self.errors.add :base, "Low quality of file! Please try again with higher quality images!"
        return false
      end
      return true
    end

    # Detect the image dimensions.
    def init_image_info
      save_dimensions
      file = self.image.queued_for_write[:original]
      if file.blank?
        file = self.image.expiring_url(:original)
      end

      if !self.name.blank?
        self.name = file.original_filename.gsub(/(.jpeg|.jpg)$/i, '') if file.original_filename =~ /(.jpeg|.jpg)$/i
      end
    end

    def init_tier
      self.tier = TIERS[:tier_1] if self.tier.blank?
    end

=begin
    #indexing with thinking sphinx
    define_index :general_images do
      # fields
      indexes name, :sortable => true
      indexes description
      indexes keyword
      indexes gallery(:name), :as => :album

      # attributes
      has gallery_id, created_at, pageview, promote_num, updated_at, data_processing
      has user(:is_banned), :as => :banned_user
      has user(:is_removed), :as => :removed_user
      has image_flags(:reported_by), :as => :flagged_by
      has user(:id), :as => :user_id
      has gallery(:permission), :as => :permission

      # weight
      set_property :field_weights => {
        :name => 15,
        :keyword => 7,
        :description => 3,
        :user => 1,
        :album => 1
      }

      set_property :delta => true
    end

    # Index for public images
    define_index :public_images do
      # fields
      indexes name, :sortable => true
      indexes keyword
      indexes author(:username), :as => :author, :sortable => true

      # attributes
      has gallery_id, created_at, pageview, promote_num, data_processing

      # weight
      set_property :field_weights => {
        :name => 7,
        :keyword => 3,
        :author => 1
      }

      where("images.id IN (SELECT id FROM (#{Image.visible_everyone.to_sql}) public_images)")

      set_property :delta => true
    end
=end
end
