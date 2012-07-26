class User < ActiveRecord::Base
  include ::SharedMethods::Paging
  include ::SharedMethods::Converter
  attr_accessor :force_submit, :login

  GENDER_MALE = "0"
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
  scope :flagged_users, lambda { 
    self.joins(%Q{
      JOIN (
        SELECT galleries.user_id,
        SUM(images_data.flagged_images_count) AS flagged_images_count
        FROM galleries JOIN (
          SELECT gallery_id, COUNT(flagged_images.id) AS flagged_images_count
          FROM (#{Image.flagged.to_sql}) AS flagged_images GROUP BY gallery_id
        ) images_data ON galleries.id = images_data.gallery_id
        GROUP BY galleries.user_id
      ) galleries_data
      ON galleries_data.user_id = users.id
    }).where("galleries_data.flagged_images_count >= ?", 3).select(
      "DISTINCT users.*, galleries_data.flagged_images_count"
    )
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

    def except_attributes
      attrs = []
      self.attribute_names.each do |n|
        if !exposed_attributes.include?(n.to_sym)
          attrs << n
        end
      end
      attrs
    end

    def default_serializable_options
      { :except => self.except_attributes,
        :methods => self.exposed_methods,
        :include => self.exposed_associations
      }
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
      if (!allow_flagged && img.source && img.source.image_flags.count > 0)
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

  # Override Rails as_json method
  def as_json(options={})
    if (!options.blank?)
      super(self.default_serializable_options.merge(options))
    else
      super(self.default_serializable_options)
    end
  end

  def exposed_methods
    self.class.exposed_methods
  end

  def exposed_attributes
    self.class.except_attributes
  end

  def exposed_associations
    self.class.exposed_associations
  end

  def except_attributes
    self.class.except_attributes
  end

  def default_serializable_options
    self.class.default_serializable_options
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

  def raw_total_sales(image_paging_params = {})
    paging_info = Image.paging_options(image_paging_params, {:sort_criteria => "images.updated_at DESC"})
    images = Image.paginate(
      :page => paging_info.page_id,
      :per_page => paging_info.page_size,
      :joins => "LEFT JOIN galleries ON galleries.id = images.gallery_id",
      :conditions => ["galleries.permission = ? and galleries.user_id = ?", Gallery::PUBLIC_PERMISSION, self.id],
      :order => paging_info.sort_string) # need sort by order date

    return images
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
