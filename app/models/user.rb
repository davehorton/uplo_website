class User < ActiveRecord::Base
  include ::SharedMethods::Paging
  attr_accessor :force_submit, :login
  
  GENDER_MALE = "0"
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, 
                  :first_name, :last_name, :username, :login, :nationality, :birthday, :gender, :avatar,
                  :twitter, :facebook
                  
  
  # Paperclip
  has_attached_file :avatar, 
   :styles => {:thumb => "180x180>" }, 
   :storage => :s3,
   :s3_credentials => "#{Rails.root}/config/amazon_s3.yml",
   :path => "user/:id/avatar/:style.:extension"
   
  # ASSOCIATIONS
  has_many :galleries, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :image_likes, :dependent => :destroy
  has_many :orders
  has_one :cart, :dependent => :destroy
  
  # VALIDATION
  validates_presence_of :first_name, :last_name, :email, :username, :message => 'cannot be blank'
  validates :password, :presence => true, :confirmation => true, :unless => :force_submit
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create, :message => 'is invalid'
  validates_uniqueness_of :email, :message => 'must be unique'
  validates_uniqueness_of :username, :message => 'must be unique'
  
  # CLASS METHODS
  class << self
    def do_search(params = {})
      params[:filtered_params][:sort_field] = 'first_name' unless params[:filtered_params].has_key?("sort_field")
      paging_info = parse_paging_options(params[:filtered_params], {:sort_mode => :extended})
      
      self.search(
        params[:query],
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
      []
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
  def fullname
    self.first_name + " " + self.last_name
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
  
  # indexing with thinking sphinx
  define_index do
    indexes first_name
    indexes last_name

    set_property :delta => true
  end
end
