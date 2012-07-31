class User < ActiveRecord::Base
  include ::SharedMethods::Paging
  include ::SharedMethods::Converter
  include ::SharedMethods::SerializationConfig

  attr_accessor :force_submit, :login

  GENDER_MALE = "0"
  MIN_FLAGGED_IMAGES = 3

  ALLOCATION_STRING = "#{RESOURCE_LIMIT[:size]} #{RESOURCE_LIMIT[:unit]}"
  ALLOCATION = FileSizeConverter.convert RESOURCE_LIMIT[:size], RESOURCE_LIMIT[:unit], FileSizeConverter::UNITS[:byte]
  FILTER_OPTIONS = ['signup_date', 'username', 'num_of_likes', 'num_of_uploads']

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :id, :email, :password, :password_confirmation, :remember_me,
                  :first_name, :last_name, :username, :login, :nationality, :birthday, :gender, :avatar,
                  :twitter, :facebook

  attr_accessible :id, :email, :password, :password_confirmation, :remember_me,
                  :first_name, :last_name, :username, :login, :nationality, :birthday, :gender, :avatar,
                  :twitter, :facebook, :is_admin, :as => :admin

  # ASSOCIATIONS
  has_many :profile_images, :dependent => :destroy, :order => 'last_used DESC'
  has_many :galleries, :dependent => :destroy
  has_many :images, :through => :galleries
  has_many :public_galleries, :conditions => ["galleries.permission = '#{Gallery::PUBLIC_PERMISSION}'"], :class_name => 'Gallery'
  has_many :public_images, :through => :public_galleries, :source => :images
  has_many :comments, :dependent => :destroy
  has_many :image_likes, :dependent => :destroy
  has_many :source_liked_images, :through => :image_likes, :source => :image
  has_many :orders
  has_one :cart, :dependent => :destroy
  has_many :user_followers, :foreign_key => :user_id, :class_name => 'UserFollow'
  has_many :followers, :through => :user_followers
  has_many :user_followings, :foreign_key => :followed_by, :class_name => 'UserFollow'
  has_many :followed_users, :through => :user_followings
  has_many :friends_images, :through => :followed_users, :source => :images
  has_many :devices, :class_name => 'UserDevice'

  # VALIDATION
  validates_presence_of :first_name, :last_name, :email, :username, :message => 'cannot be blank'
  validates :password, :presence => true, :confirmation => true, :unless => :force_submit
  validates_format_of :email, :on => :create, :message => 'is invalid',
          :with => /^([0-9a-zA-Z]([-.\w]*[0-9a-zA-Z])*@(([0-9a-zA-Z])+([-\w]*[0-9a-zA-Z])*\.)+[a-zA-Z]{2,9})$/i
  validates_format_of :website, :allow_blank => true,
          :with => /(^$)|(^((http|https):\/\/){0,1}[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/i
  validates_uniqueness_of :email, :message => 'must be unique'
  validates_uniqueness_of :username, :message => 'must be unique'
  validates_length_of :first_name, :last_name, :in => 2..30, :message => 'must be 2 - 30 characters in length'

  # SCOPE
  scope :active_users, where(:is_removed => false, :is_banned => false)
  scope :removed_users, where(:is_removed => true)
  scope :flagged_users, lambda {
    self.joins(%Q{
      JOIN (
        SELECT galleries.user_id,
        SUM(images_data.flagged_images_count) AS flagged_images_count
        FROM galleries JOIN (
          SELECT gallery_id, COUNT(flagged_images.id) AS flagged_images_count
          FROM (#{Image.removed_or_flagged_images.to_sql}) AS flagged_images GROUP BY gallery_id
        ) images_data ON galleries.id = images_data.gallery_id
        GROUP BY galleries.user_id
      ) galleries_data
      ON galleries_data.user_id = users.id
    }).where("users.is_banned = ? OR galleries_data.flagged_images_count >= ?", true, MIN_FLAGGED_IMAGES).select(
      "DISTINCT users.*, galleries_data.flagged_images_count")
  }

  # CLASS METHODS
  class << self
    def load_users(params = {})
      case params[:sort_field]
        when 'signup_date' then
          params[:sort_field] = "users.created_at"
          self.load_users_with_images_statistics(params)
        when 'username' then
          params[:sort_field] = "users.username"
          self.load_users_with_images_statistics(params)
        when 'num_of_likes' then
          params[:sort_field] = 'galleries_data.images_likes_count'
          self.load_users_with_images_statistics(params)
        when 'num_of_uploads' then
          params[:sort_field] = 'galleries_data.images_count'
          self.load_users_with_images_statistics(params)
        else
          paging_info = parse_paging_options(params)
          self.paginate(
            :page => paging_info.page_id,
            :per_page => paging_info.page_size,
            :order => paging_info.sort_string
          )
      end
    end

    # Load users data with images_likes_count, images_count and images_pageview.
    def load_users_with_images_statistics(params = {})
      paging_info = parse_paging_options(params)
      self.joins(%Q{
        LEFT JOIN (
          SELECT galleries.user_id,
          SUM(images_data.images_count) AS images_count,
          SUM(images_data.images_likes_count) AS images_likes_count,
          SUM(images_data.images_pageview) AS images_pageview
          FROM galleries LEFT JOIN (
            SELECT gallery_id, COUNT(images.id) AS images_count,
            SUM(likes) AS images_likes_count,
            SUM(pageview) AS images_pageview
            FROM images GROUP BY gallery_id
          ) images_data ON galleries.id = images_data.gallery_id
          GROUP BY galleries.user_id
        ) galleries_data
        ON galleries_data.user_id = users.id
      }).select("DISTINCT users.*, galleries_data.images_count,
                galleries_data.images_likes_count,
                galleries_data.images_pageview").paginate(
        :page => paging_info.page_id,
        :per_page => paging_info.page_size,
        :order => paging_info.sort_string
      )
    end

    def do_search(params = {})
      params[:filtered_params][:sort_field] = 'first_name' unless params[:filtered_params].has_key?("sort_field")
      paging_info = parse_paging_options(params[:filtered_params], {:sort_mode => :extended})

      self.search(
        SharedMethods::Converter::SearchStringConverter.process_special_chars(params[:query]),
        :star => true,
        :page => paging_info.page_id,
        :per_page => paging_info.page_size )
    end

    # Override Devise method so that User can log in with username or email.
    def find_for_database_authentication(warden_conditions)
      conditions = warden_conditions.dup
      login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value",
                              { :value => login.strip.downcase }]).first
    end

    def exposed_methods
      [:avatar_url, :fullname, :joined_date, :biography]
    end

    def exposed_attributes
      [:id, :email, :first_name, :last_name, :username, :nationality, :birthday, :gender, :twitter, :facebook]
    end

    def exposed_associations
      []
    end

    def remove_flagged_users
      self.transaction do
        self.flagged_users.each do |user|
          user.remove
        end
      end
    end

    def reinstate_flagged_users
      self.transaction do
        self.flagged_users.each do |user|
          user.reinstate
        end
      end
    end

    protected

    def parse_paging_options(options, default_opts = {})
      if default_opts.blank?
        default_opts = {
          :sort_criteria => "users.updated_at DESC"
        }
      end
      paging_options(options, default_opts)
    end
  end

  # PUBLIC INSTANCE METHODS
  def liked_images
    self.source_liked_images.avai_images.joins('LEFT JOIN galleries ON galleries.id = images.gallery_id').where(
      "galleries.permission = '#{Gallery::PUBLIC_PERMISSION}' OR
      (galleries.permission = '#{Gallery::PRIVATE_PERMISSION}' AND galleries.user_id = #{ self.id })"
    )
  end

  def avatar(allow_flagged=true)
    img = ProfileImage.find :first, :conditions => {:user_id => self.id, :default => true}
    if img.nil?
      result = nil
    else
      if img.source && (img.source.is_removed || (!allow_flagged && img.source.is_flagged?))
        return nil
      end
      result = img.data
    end
    return result
  end

  def joined_date
    if !self.confirmed_at.nil?
      return self.confirmed_at.strftime('%B %Y')
    end
    return ""
  end

  def fullname
    [self.first_name, self.last_name].join(" ")
  end

  # allow_flagged=true: show avatar even when flagged
  def avatar_url(style='thumb', allow_flagged=false)
    avatar = self.avatar(allow_flagged)
    if avatar.nil?
      url = "/assets/avatar-default-#{style.to_s}.jpg"
    else
      url = avatar.url(style.to_sym)
    end
    return url
  end

  # Generate email address including full name.
  def friendly_email
    "#{self.fullname} <#{self.email}>"
  end

  # Override attribute setter.
  def birthday=(date)
    if date.is_a?(String)
      date = ::Util.format_date(date)
      if date
        date = date.to_date
      end
    end
    self.send(:write_attribute, :birthday, date)
  end

  def update_profile(params)
    result = nil
    params ||= {}
    params.to_options!
    [:username, :email].each do |key|
      # Remove sensitive parameter.
      params.delete(key)
    end

    # If there is any password parameter we will update user info with password.
    if !params[:current_password].blank? &&
          (params.has_key?(:password) ||
           params.has_key?(:password_confirmation))
      result = self.update_with_password(params)
    else
      # Update without password
      [:password, :password_confirmation].each do |key|
        # Remove sensitive parameter.
        params.delete(key)
      end

      # TODO: inspect why this method does not work?
      #result = self.update_without_password(params)
      self.force_submit = true
      result = self.update_attributes(params)
    end

    result
  end

  def is_male?
    (self.gender.to_s == GENDER_MALE)
  end

  def has_follower?(user_id)
    return UserFollow.exists?({ :user_id => self.id, :followed_by => user_id })
  end

  def has_profile_photo?(photo_id)
    return ProfileImage.exists?({:user_id => self.id, :id => photo_id})
  end

  def gender_string
    key = "female"
    if self.is_male?
      key = "male"
    end
    return I18n.t("common.#{key}")
  end

  def recent_empty_order
    empty_order = self.orders.where(:status => Order::STATUS[:shopping]).order("orders.created_at DESC").first
    if empty_order.blank?
      empty_order = self.orders.create(:status => Order::STATUS[:shopping])
    end
    empty_order
  end

  def init_cart
    if self.cart.blank?
      new_order = self.recent_empty_order
      new_cart = self.create_cart(:order => new_order)
    elsif self.cart.order.blank?
      self.cart.order = self.recent_empty_order
      self.cart.save
    end

    return self.cart
  end

  def used_allocation
    total = 0
    self.galleries.each do |gal|
      gal.images.each do |img|
        total += img.data_file_size
      end
    end
    return total
  end

  def free_allocation
    remaining = ALLOCATION
    self.galleries.each do |gal|
      gal.images.each do |img|
        remaining -= img.data_file_size
      end
    end
    return remaining
  end

  def paid_items(image_id=nil)
    if image_id.blank?
      from_condition = '(SELECT * FROM line_items) AS lis'
    else
      from_condition = "(SELECT * FROM line_items WHERE line_items.image_id=#{image_id}) AS lis"
    end
    items = LineItem.all :from => from_condition, :select => 'lis.*',
      :joins => 'LEFT JOIN orders ON orders.id = lis.order_id',
      :conditions => ['orders.user_id=? and orders.transaction_status=?',
        self.id, Order::TRANSACTION_STATUS[:complete]]
    return items
  end

  def paid_items_number(image_id=nil)
    result = 0
    items = self.paid_items(image_id)
    items.each {|item| result += item.quantity }
    return result
  end

  def total_paid(image_id=nil)
    result = 0
    items = self.paid_items(image_id)
    items.each {|item| result += item.quantity * (item.tax + item.price) }
    return result
  end

#===============================================================================
# Description:
# - get saled ($) and saled quantity of each images
# - sort by highest saled ($)
# Note:
#===============================================================================
  def raw_sales(paging_params = {})
    paging_info = Image.parse_paging_options(paging_params)
    images = Image.paginate(
      :page => paging_info.page_id,
      :per_page => paging_info.page_size,
      :select => ' img.*, purchased_items.saled AS sales,
                   purchased_items.saled_quantity AS quantity_sales',
      :from => "
        ( SELECT    images.*
          FROM      images
          LEFT JOIN galleries ON galleries.id = images.gallery_id
          WHERE     galleries.user_id = #{ self.id })
        AS img",
      :joins => "
        LEFT JOIN
          ( SELECT    l.image_id AS image_id,
                      SUM(l.quantity *(l.tax+l.price)) AS saled,
                      SUM(l.quantity) AS saled_quantity
            FROM      line_items AS l
            LEFT JOIN orders ON orders.id = l.order_id
            WHERE     orders.transaction_status = '#{ Order::TRANSACTION_STATUS[:complete] }'
            GROUP BY  l.image_id )
        AS purchased_items
        ON purchased_items.image_id = img.id",
      :order => "(CASE WHEN purchased_items.saled IS NULL THEN 0 ELSE 1 END) desc,
                 purchased_items.saled DESC, img.name ASC"
    )
    return images
  end

#===============================================================================
# Description:
# - get sales of all images over months
# - report over nearest 12 months from report date
# Note:
#===============================================================================
  def monthly_sales(report_date=Time.now)
    result = []
    date = DateTime.parse report_date.to_s
    prior_months = SharedMethods::TimeCalculator.prior_year_period(date, {:format => '%b'})
    prior_months.each { |mon|
      total_sales = 0
      self.images.each { |img| total_sales += img.total_sales(mon) }
      result << { :month => mon, :sales => total_sales }
    }
    return result
  end

  def total_sales(image_paging_params = {})
    result = {:total_entries => 0, :data => []}
    paging_info = Image.paging_options(image_paging_params, {:sort_criteria => "images.updated_at DESC"})
    images = Image.paginate(
      :page => paging_info.page_id,
      :per_page => paging_info.page_size,
      :joins => "LEFT JOIN galleries ON galleries.id = images.gallery_id",
      :conditions => ["galleries.permission = ? and galleries.user_id = ?", Gallery::PUBLIC_PERMISSION, self.id],
      :order => paging_info.sort_string) # need sort by order date

    images.each { |img|
      info = img.serializable_hash(img.default_serializable_options)
      info[:total_sale] = img.total_sales
      info[:quantity_sale] = img.saled_quantity
      result[:data] << {:image => info }
    }
    result[:total_entries] = images.total_entries
    return result
  end

  def oldest_profile_image
    result = nil
    last_time = Time.now
    self.profile_images.each do |img|
      if img.last_used < last_time
        last_time = img.last_used
        result = img.id
      end
    end
    return result
  end

  def recent_profile_image
    result = nil
    recent_time = Time.parse '0000-1-1'
    self.profile_images.each do |img|
      if img.last_used > recent_time
        recent_time = img.last_used
        result = img.id
      end
    end
    return result
  end

  def hold_profile_images
    result = true
    if ProfileImage.count(:conditions => {:user_id => self.id}) > HELD_AVATARS_NUMBER
      begin
        ProfileImage.destroy self.oldest_profile_image
      rescue
        result = false
      end
    end
    return result
  end

  def rollback_avatar
    id = self.recent_profile_image
    if id.nil?
      result = true
    else
      img = ProfileImage.find_by_id id
      img.update_attribute('default', true)
    end
    return result
  end

  def images_count
    if !self.attributes.has_key?('images_count')
      self.attributes['images_count'] = self.images.avai_images.count
    else
      self.attributes['images_count'].to_i
    end
  end

  def images_likes_count
    if !self.attributes.has_key?('images_likes_count')
      self.attributes['images_likes_count'] = self.images.avai_images.sum(:likes)
    else
      self.attributes['images_likes_count'].to_i
    end
  end

  def images_pageview
    if !self.attributes.has_key?('images_pageview')
      self.attributes['images_pageview'] = self.images.avai_images.sum(:pageview)
    else
      self.attributes['images_pageview'].to_i
    end
  end

  def remove
    self.class.transaction do
      self.update_attribute(:is_removed, true)
      self.remove_flagged_images
    end
  end

  def remove_flagged_images
    self.images.flagged.update_all(:is_removed => true)
  end

  def reinstate
    self.class.transaction do
      self.update_attribute(:is_banned, false)
      self.reinstate_flagged_images
    end
  end

  def reinstate_flagged_images
    Image.transaction do
      self.images.removed_or_flagged_images.each do |image|
        image.reinstate
      end
    end
  end

  # Detect if this user is ready for being flagged.
  def will_be_banned?
    (!self.is_banned && self.images.flagged.length >= MIN_FLAGGED_IMAGES)
  end

  # indexing with thinking sphinx
  define_index do
    indexes first_name
    indexes last_name
    indexes username

    if Rails.env.production?
      set_property :delta => FlyingSphinx::DelayedDelta
    else
      set_property :delta => true
    end
  end
end
