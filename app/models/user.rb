class User < ActiveRecord::Base
  include ::SharedMethods::Paging
  include ::SharedMethods::Converter
  attr_accessor :force_submit, :login

  GENDER_MALE = "0"
  ALLOCATION_STRING = "#{RESOURCE_LIMIT[:size]} #{RESOURCE_LIMIT[:unit]}"
  ALLOCATION = FileSizeConverter.convert RESOURCE_LIMIT[:size], RESOURCE_LIMIT[:unit], FileSizeConverter::UNITS[:byte]

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :id, :email, :password, :password_confirmation, :remember_me,
                  :first_name, :last_name, :username, :login, :nationality, :birthday, :gender, :avatar,
                  :twitter, :facebook

  # Paperclip
  has_attached_file :avatar,
   :styles => {:thumb => "180x180>", :large => '67x67#', :medium => "48x48>", :small => '24x24>' },
   :storage => :s3,
   :s3_credentials => "#{Rails.root}/config/amazon_s3.yml",
   :path => "user/:id/avatar/:style.:extension",
   :default_url => "/assets/avatar-default-:style.jpg"

  # ASSOCIATIONS
  has_many :galleries, :dependent => :destroy
  has_many :images, :through => :galleries
  has_many :public_galleries, :conditions => ["galleries.permission = '#{Gallery::PUBLIC_PERMISSION}'"], :class_name => 'Gallery'
  has_many :public_images, :through => :public_galleries, :source => :images
  has_many :comments, :dependent => :destroy
  has_many :image_likes, :dependent => :destroy
  has_many :orders
  has_one :cart, :dependent => :destroy
  has_many :user_followers, :foreign_key => :user_id, :class_name => 'UserFollow'
  has_many :followers, :through => :user_followers
  has_many :user_followings, :foreign_key => :followed_by, :class_name => 'UserFollow'
  has_many :followed_users, :through => :user_followings

  # VALIDATION
  validates_presence_of :first_name, :last_name, :email, :username, :message => 'cannot be blank'
  validates :password, :presence => true, :confirmation => true, :unless => :force_submit
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create, :message => 'is invalid'
  validates_uniqueness_of :email, :message => 'must be unique'
  validates_uniqueness_of :username, :message => 'must be unique'

  # CLASS METHODS
  class << self
    def load_users(params = {})
      paging_info = parse_paging_options(params)
      paginate(
        :page => paging_info.page_id,
        :per_page => paging_info.page_size,
        :order => paging_info.sort_string)
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
  def biography
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. In non quam eu ipsum tincidunt iaculis in id augue. Mauris auctor rhoncus sollicitudin."
  end

  def joined_date
    self.confirmed_at.strftime('%B %Y')
  end

  def fullname
    [self.first_name, self.last_name].join(" ")
  end

  def avatar_url
    self.avatar.url(:thumb)
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
