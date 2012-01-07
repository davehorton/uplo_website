class User < ActiveRecord::Base
  attr_accessor :force_submit, :login
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, 
                  :first_name, :last_name, :username, :login, :nationality, :birthday, :gender, :avatar
                  
  
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
  
  # VALIDATION
  validates_presence_of :first_name, :last_name, :email, :username, :message => 'This field cannot be blank'
  validates :password, :presence => true, :confirmation => true, :unless => :force_submit
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create, :message => 'Email is invalid'
  validates_uniqueness_of :email, :message => 'Email must be unique'
  validates_uniqueness_of :username, :message => 'Username must be unique'
  
  # CLASS METHODS
  class << self
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
      [:id, :email, :first_name, :last_name, :username, :nationality, :birthday, :gender]
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
  end
  
  # PUBLIC INSTANCE METHODS
  def fullname
    self.first_name + " " + self.last_name
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
end
