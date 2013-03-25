class Image < ActiveRecord::Base
  include ::Shared::QueryMethods
  include ImageConstants

  belongs_to :active_user, class_name: 'User', foreign_key: 'user_id', conditions: { banned: false, removed: false }
  belongs_to :user, counter_cache: true
  belongs_to :gallery,     :touch => true
  belongs_to :public_gallery, class_name: 'Gallery', foreign_key: 'gallery_id', conditions: { permission: Permission::Public.new.to_s }

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
    :content_type => { :content_type => [ 'image/jpeg','image/jpg' ],
    :message => 'File type must be one of [.jpeg, .jpg]' }, :on => :create
  validate :validate_quality, :on => :create

  process_in_background :image

  before_create :init_tier, :set_as_cover_if_first_one, :set_user
  before_destroy :ensure_not_associated_with_an_order
  before_post_process :init_image_info

  default_scope order('images.created_at desc')
  scope :removed,     where(removed: true)
  scope :not_removed, where(removed: false)

  scope :flagged,     not_removed.joins(:image_flags).readonly(false)
  scope :unflagged,   not_removed.includes(:image_flags).where(image_flags: { id: nil }).readonly(false)

  scope :processing,    not_removed.joins(:active_user).where(image_processing: true)
  scope :visible,       not_removed.joins(:active_user).where(image_processing: false)
  scope :public_access, visible.unflagged.joins(:public_gallery)

  scope :spotlight, where(promoted: true)
  scope :with_gallery, includes(:gallery)

  def self.flagged_of_type(image_flag_type = nil)
    images = Image.flagged
    images = images.where(image_flags: { flag_type: image_flag_type }) if image_flag_type.present?
    images
  end

  def self.remove_all_flagged_images(flag_type = nil)
    images = Image.flagged_of_type(flag_type)
    images.each(&:remove!)
  end

  def self.reinstate_all_flagged_images(flag_type = nil)
    images = Image.flagged_of_type(flag_type)
    images.each(&:reinstate!)
  end

  def self.search_scope(query)
    images = Image.scoped
    if query.present?
      query = query.gsub(/[[:punct:]]/, ' ').squish
      images = images.advanced_search_by_name_or_description_or_keyword(query, query, query)
    end
    images
  end

  def self.public_or_owner(user)
    joins(:gallery).where("images.user_id = ? or galleries.permission = ?", user, Permission::Public.new.to_s)
  end

  # re-implements Shared::QueryMethods function
  # by replacing search fields before calling super
  def self.paginate_and_sort(params = {})
    image_params = params

    # TODO: can't we just use the same values in the front-end/API
    # so that we don't have to scrub them here?
    if sort_field = params[:sort_field]
      image_params[:sort_field] = case sort_field
        when 'date_uploaded' then
          'images.created_at'
        when 'num_of_views' then
          'images.pageview'
        when 'num_of_likes' then
          'images.image_likes_count'
        else
          sort_field
        end
    end

    super(image_params)
  end

  def self.popular_with_pagination(params = {})
    params[:sort_expression] = "images.promoted desc, images.updated_at desc, images.image_likes_count desc"
    public_access.paginate_and_sort(params)
  end

  # reprocesses images based on any new sizes
  def self.rebuild_all_photos
    Image.find_each do |image|
      image.image.reprocess!
    end
  end

  delegate :username, :to => :user, allow_nil: true
  delegate :id, :fullname, :to => :user, allow_nil: true, prefix: true
  delegate :name, :to => :gallery, prefix: true

  def gallery_cover=(is_cover)
    gallery.images.update_all(gallery_cover: false) if is_cover
    super
  end

  def owner_avatar=(is_owner_avatar)
    user.images.where(owner_avatar: true).update_all(owner_avatar: false) if is_owner_avatar
    super
  end

  def get_price(moulding, size)
    Product.where(moulding_id: moulding.id, size_id: size.id).first.price_for_tier(tier_id)
  end

  def get_commission
    return IMAGE_COMMISSIONS[self.tier]
  end

  def sample_product_price
    Product.where(size_id: printed_sizes.first.id).first.try(:price_for_tier, tier_id) || 'Unknown'
  end

  def square?
    ratio = self.width*1.0 / self.height
    threshold = (1 + (RECTANGULAR_RATIO - 1)/2)

    (1.0/threshold < ratio)
  end

  def valid_for_size?(size)
    if square?
      edge = [self.width, self.height].min
      (edge / PRINT_RESOLUTION) >= size.width
    elsif size.rectangular?
      short_edge = [self.width, self.height].min
      long_edge  = [self.width, self.height].max
      (short_edge / PRINT_RESOLUTION) >= size.width && (long_edge / PRINT_RESOLUTION) >= size.height
    end
  end

  def printed_sizes
    sizes = if square?
      Size.square.where(id: Product.all.map(&:size_id))
    else
      Size.rectangular.where(id: Product.all.map(&:size_id))
    end

    sizes.select { |s| valid_for_size?(s) }
  end

  def comments_number
    self.comments.count
  end

  def flagged?
    image_flags.any?
  end

  def flag!(flagged_by_user, params={})
    return { success: false, msg: "The author is already banned." } if self.user.banned?
    return { success: false, msg: "This image is already flagged." } if image_flags.any?
    return { success: false, msg: "You cannot flag your own image." } if flagged_by_user == user

    flag = ImageFlag.new(
             image_id:    id,
             reported_by: flagged_by_user.id,
             flag_type:   params[:type],
             description: params[:desc]
           )

    if flag.save
      # Remove all images in shopping carts
      line_items = LineItem.readonly(false).joins(:image, :order).
        where(images: { id: id }).
        where("status = '#{Order::STATUS[:shopping]}' OR status = '#{Order::STATUS[:checkout]}'")

      transaction do
        line_items.each do |line_item|
          line_item.update_attribute(:quantity, 0)
        end
      end

      if user.ban_threshold_met?
        user.ban!
      else
        UserMailer.delay.flagged_image_email(user.id, id)
      end

      return { success: true }
    else
      return { success: false, msg: flag.errors.full_messages.join(', ') }
    end
  end

  def reinstate!
    transaction do
      image_flags.destroy_all
      self.removed = false
      save!
      UserMailer.delay.flagged_image_reinstated_email(user_id, id)
    end
  end

  def promote!
    self.promoted = true
    save!
  end

  def demote!
    self.promoted = false
    save!
  end

  def remove!
    self.removed = true
    save!
    UserMailer.delay.flagged_image_removed_email(user_id, id)
  end

  def url(options = nil)
    storage = Rails.application.config.paperclip_defaults[:storage]
    case storage
      when :s3 then self.image.expiring_url(s3_expire_time, options)
      when :filesystem then image.url(options)
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

  def total_sales(month = nil)
    total = 0

    orders = self.orders.completed

    if month
      start_date = DateTime.parse("01 #{month}")
      end_date = TimeCalculator.last_day_of_month(start_date.mon, start_date.year).end_of_day
      end_date = end_date.strftime("%Y-%m-%d %T")
      start_date = start_date.strftime("%Y-%m-%d %T")
      orders = orders.where("transaction_date > ? and transaction_date < ?", start_date, end_date)
    end

    order_ids = orders.collect(&:id)
    sold_items = (orders.length == 0) ? [] : line_items.where(order_id: order_ids)
    sold_items.each do |item|
      total += ((item.price * item.quantity) * item.commission_percent)
    end

    total
  end

  # mon with year, return sold quantity
  def sold_quantity(month = nil)
    result = 0

    if month.nil?
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
    saled_items = (orders.length==0) ? [] : self.line_items.where(order_id: orders_in)
    saled_items.each { |item| result += item.quantity }
    return result
  end

  def raw_purchased_info(item_paging_params = {})
    result = {:data => [], :total => 0}
    order_ids = orders.completed.map(&:id)

    sold_items = []

    if order_ids.any?
      sold_items = LineItem.paginate_and_sort(item_paging_params.merge(sort_expression: 'purchased_date desc')).
        joins("LEFT JOIN orders ON orders.id = line_items.order_id LEFT JOIN users ON users.id = orders.user_id").
        select("line_items.*, users.id as purchaser_id, orders.transaction_date as purchased_date").
        where(image_id: id, order_id: order_ids)
    end

    sold_items
  end

  def get_purchased_info(item_paging_params = {})
    result = {:data => [], :total_quantity => 0, :total_sale => 0}
    order_ids = self.orders.completed.map(&:id)

    if order_ids.any?
      sold_items = LineItem.paginate(item_paging_params.merge(sort_expression: 'purchased_date desc')).
        joins("LEFT JOIN orders ON orders.id = line_items.order_id LEFT JOIN users ON users.id = orders.user_id").
        select("line_items.*, users.id as purchaser_id, orders.transaction_date as purchased_date").
        where(image_id: id, order_id: order_ids)

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
        result << { :month => short_mon, :sales => self.total_sales(mon) }
      elsif options.has_key?(:report_by)
        result << {
          :month => short_mon,
          :sales => (options[:report_by]==SALE_REPORT_TYPE[:price]) ? total_sales(mon) : sold_quantity(mon)
        }
      end
    }
    return result
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

  def available_styles
    result = DEFAULT_STYLES
    printed_sizes.each do |size|
      ratios = size.to_a
      tmp_width = 0
      tmp_height = 0
      if square?
        tmp_width = height = size.width * PRINT_RESOLUTION
      elsif self.width > self.height
        tmp_width = ratios.max * PRINT_RESOLUTION
        tmp_height = ratios.min * PRINT_RESOLUTION
      else
        tmp_width = ratios.min * PRINT_RESOLUTION
        tmp_height = ratios.max * PRINT_RESOLUTION
      end
      result["scale#{size.to_name}".to_sym] = "#{tmp_width}x#{tmp_height}#"
      ratio = tmp_width/640.to_f
      ratio = 1 if ratio < 1
      preview_width = tmp_width / ratio
      preview_height = tmp_height / ratio
      result["scale_preview#{size.to_name}".to_sym] = "#{preview_width.to_i}x#{preview_height.to_i}#"
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

    def ensure_not_associated_with_an_order
      return false if orders.any?
    end

    def s3_expire_time
      Time.zone.now.beginning_of_day.since 25.hours
    end

    def validate_quality
      save_dimensions
      min_size = square? ? Size.square.first : Size.rectangular.first
      if !valid_for_size?(min_size)
        self.errors.add :base, "Quality of image is not high enough for printing. Please try uploading a larger image."
        false
      end
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
      self.tier_id ||= 1
    end

    def set_as_cover_if_first_one
      self.gallery_cover = true unless Image.exists?(gallery_id: gallery_id, gallery_cover: true)
    end

    def set_user
      self.user_id = gallery.user_id
    end
end
