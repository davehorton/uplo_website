class User < ActiveRecord::Base
  attr_accessor :force_submit
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name
  
  # Paperclip
  has_attached_file :avatar, 
   :styles => {:thumb => "180x180>" }, 
   :storage => :s3,
   :s3_credentials => "#{Rails.root}/config/amazon_s3.yml",
   :path => "user/:id/:style.:extension"
   
  # ASSOCIATIONS
  has_many :galleries, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :image_likes, :dependent => :destroy
  
  # VALIDATION
  validates_presence_of :first_name, :last_name, :email, :message => 'This field cannot be blank'
  validates :password, :presence => true, :confirmation => true, :unless => :force_submit
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create, :message => 'Email is invalid'
  validates_uniqueness_of :email, :message => 'Email must be unique'
  
  # CALLBACK
  
  def full_name
    self.first_name + " " + self.last_name
  end
end
