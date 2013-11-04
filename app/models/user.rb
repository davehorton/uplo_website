require 'valid_email'

class User < ActiveRecord::Base
  class NotReadyForReinstatingError < StandardError
  end

  include ::Shared::QueryMethods

  attr_accessor :force_submit, :login, :skip_state_changed_tracking

  GENDER_MALE = "0"
  MIN_FLAGGED_IMAGES = 3
  FILTER_OPTIONS = ['signup_date', 'username', 'num_of_likes']
  SEARCH_TYPE = 'users'
  SORT_OPTIONS = { :name => 'name', :date_joined => 'date' }
  SORT_CRITERIA = {
    SORT_OPTIONS[:name] => 'username ASC',
    SORT_OPTIONS[:date_joined] => 'date_joined DESC'
  }

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :authentication_keys => [:login]

  attr_protected :admin,
                 :removed,
                 :banned,
                 :current_sign_in_ip,
                 :last_sign_in_ip,
                 :current_sign_in_at,
                 :last_sign_in_at,
                 :sign_in_count,
                 :confirmed_at,
                 :created_at

  # make string column behave like a date
  begin
    class << columns_hash['expiration']
      def type
        :date
      end
    end
  rescue
  end

  belongs_to :billing_address,  :class_name => "Address", :foreign_key => :billing_address_id
  belongs_to :shipping_address, :class_name => "Address", :foreign_key => :shipping_address_id

  has_many :authentications

  has_many :galleries, :dependent => :destroy
  has_many :public_galleries, class_name: 'Gallery', conditions: { permission: Permission::Public.new.to_s }
  has_many :gallery_invitations

  has_many :images
  has_many :public_images, :through => :public_galleries, :source => :images
  has_many :profile_images, :dependent => :destroy, :order => 'updated_at DESC'

  has_many :image_likes, :dependent => :destroy
  has_many :source_liked_images, :through => :image_likes, :source => :image

  has_many :comments, :dependent => :destroy
  has_many :devices, :class_name => 'UserDevice'
  has_many :orders

  has_many :user_followers, :foreign_key => :user_id, :class_name => 'UserFollow'
  has_many :followers, :through => :user_followers
  has_many :user_followings, :foreign_key => :followed_by, :class_name => 'UserFollow'
  has_many :followed_users, :through => :user_followings
  has_many :friends_images, :through => :followed_users, :source => :images

  has_one  :cart, :dependent => :destroy
  has_one  :user_notification, :dependent => :destroy

  accepts_nested_attributes_for :billing_address
  accepts_nested_attributes_for :shipping_address

  validates_presence_of :first_name, :last_name, :username, :message => 'cannot be blank'
  validates :password, :presence => true, :confirmation => true, :if => :check_password?
  validates_format_of :website, :allow_blank => true,
          :with => /(^$)|([a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
  validates_uniqueness_of :username, :message => 'is taken. Choose another one.'

  validates_length_of :first_name, :in => 1..30
  validates_length_of :last_name,  :in => 1..30
  validates_confirmation_of :paypal_email, :message => "should match confirmation"

  validates_presence_of :paypal_email_confirmation, :if => :paypal_email_changed?
  validates :paypal_email, :email => true, :if => :paypal_email_changed?

  before_save :scrub_sensitive_fields
  after_create :create_user_notification

  default_scope where(removed: false, banned: false).order('users.username asc')

  scope :not_removed,   where(removed: false)
  scope :removed_users, where(removed: true)
  scope :flagged_users, not_removed.where(banned: true)
  scope :confirmed, not_removed.where("confirmed_at IS NOT NULL")

  scope :reinstate_ready_users, flagged_users.joins(self.sanitize_sql([
    "LEFT JOIN (
        SELECT galleries.user_id,
        SUM(images_data.flagged_images_count) AS flagged_images_count
        FROM galleries JOIN (
          SELECT gallery_id, COUNT(flagged_images.id) AS flagged_images_count
          FROM (#{Image.flagged.to_sql}) AS flagged_images GROUP BY gallery_id
        ) images_data ON galleries.id = images_data.gallery_id
        GROUP BY galleries.user_id
      ) galleries_data
      ON galleries_data.user_id = users.id
      AND galleries_data.flagged_images_count < ? ",
      MIN_FLAGGED_IMAGES])
    ).select("DISTINCT users.*, galleries_data.flagged_images_count")

  def self.search_scope(query)
    users = User.scoped
    if query.present?
      if query.match(/[[:space:]]/)
        first_name, last_name = query.split
        users = users.where("users.first_name ILIKE (?) OR users.last_name ILIKE (?)", "#{first_name}%", "#{last_name}%")
      else
        query = "#{query}%"
        users = users.where("users.username ILIKE (?) OR users.first_name ILIKE (?) OR users.last_name ILIKE (?)", query, query, query)
      end
    end
    users
  end
  # re-implements Shared::QueryMethods function
  # by replacing search fields before caling super
  def self.paginate_and_sort(params = {})
    user_params = params

    # TODO: can't we just use the same values in the front-end/API
    # so that we don't have to scrub them here?
    if sort_field = params[:sort_field]
      user_params[:sort_field] = case sort_field
        when 'signup_date' then
          'users.created_at'
        when 'username' then
          'users.username'
        when 'num_of_likes' then
          'users.image_likes_count'
        else
          sort_field
        end
    end

    super(user_params)
  end

  # Override Devise method so that User can log in with username or email.
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def self.remove_flagged_users
    self.transaction do
      self.reinstate_ready_users.each do |user|
        user.remove!
      end
    end
  end

  def self.reinstate_flagged_users
    self.transaction do
      self.reinstate_ready_users.each do |user|
        user.reinstate
      end
    end
  end

  def to_param
    "#{id}-#{username.parameterize}"
  end

  def liked_images
    source_liked_images.unflagged.public_or_owner(self)
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

  def avatar
    img = ProfileImage.find :first, :conditions => {:user_id => self.id, :default => true}
    if img.nil?
      result = nil
    else
      if img.source && (img.source.removed? || (img.source.flagged?))
        return nil
      end
      result = img
    end
    return result
  end

  def avatar_url(style='thumb')
    protocol = Rails.env.production? ? 'https' : 'http'

    if avatar.nil?
      "#{protocol}://#{DOMAIN}/assets/avatar-default-#{style.to_s}.jpg"
    else
      storage = Rails.application.config.paperclip_defaults[:storage]
      case storage
        when :s3 then avatar.url(style.to_sym)
        when :filesystem then "#{protocol}://#{DOMAIN}#{avatar.url(style.to_sym)}"
      end
    end
  end

  # Generate email address including full name.
  def friendly_email
    "#{self.fullname} <#{self.email}>"
  end

  # Override attribute setter.
  def birthday=(date)
    if date.is_a?(String)
      date = DateTime.strptime(date, I18n.t("date.formats.default"))
      date = date.to_date if date
    end
    self[:birthday] = date
    self.save!
  end

  def update_profile(params, type_update='')
    result = nil
    params.to_options!
    params.delete(:username)

    self.attributes = params.except(:current_password, :password, :password_confirmation)

    if type_update == 'payment_info'
      credit_card = CreditCard.build_card_from_param(params)
      return false if !credit_card.valid?
      PaymentInfo.create_payment_profile(self, credit_card)
    elsif billing_address.try(:valid?) && billing_address.try(:changed?) && an_customer_payment_profile_id?
      PaymentInfo.update_billing_address(self)
    end

    if params[:current_password].present? &&
          (params.has_key?(:password) ||
           params.has_key?(:password_confirmation))
      result = self.update_with_password(params)
    else
      [:current_password, :password, :password_confirmation].each do |key|
        params.delete(key)
      end

      result = self.update_without_password(params)
    end

    result
  end

  def male?
    gender.to_s == GENDER_MALE
  end

  def has_follower?(user_id)
    UserFollow.exists?(user_id: self.id, followed_by: user_id)
  end

  def has_profile_photo?(photo_id)
    ProfileImage.exists?(user_id: self.id, id: photo_id)
  end

  def gender_string
    key = male? ? "male" : "female"
    I18n.t("common.#{key}")
  end

  def recent_empty_order
    self.orders.where(:status => Order::STATUS[:shopping]).first_or_create!
  end

  def init_cart
    if cart.nil?
      create_cart(:order => recent_empty_order)
    elsif cart.order.nil?
      cart.assign_empty_order!
    end
    cart
  end

  def paid_items(image_id=nil)
    if image_id.blank?
      from_condition = '(SELECT * FROM line_items) AS lis'
    else
      from_condition = "(SELECT * FROM line_items WHERE line_items.image_id=#{image_id}) AS lis"
    end
    LineItem.all :from => from_condition, :select => 'lis.*',
      :joins => 'LEFT JOIN orders ON orders.id = lis.order_id',
      :conditions => ['orders.user_id=? and orders.status=?',
        self.id, Order::STATUS[:complete]]
  end

  def paid_items_number(image_id=nil)
    result = 0
    items = self.paid_items(image_id)
    items.each {|item| result += item.quantity }
    result
  end

  def total_paid(image_id=nil)
    result = 0
    items = self.paid_items(image_id)
    items.each {|item| result += item.quantity * (item.tax + item.price) }
    result
  end

  def sold_items
    LineItem.sold_items.where(images: { user_id: id })
  end

  #==============================================================================
  # Description:
  # - get sales of all images over months
  # - report over nearest 12 months from report date
  # Note:
  #
  #==============================================================================
  def monthly_sales(report_date=Time.now)
    result = []
    date = DateTime.parse report_date.to_s
    prior_months = TimeCalculator.prior_year_period(date, {:format => '%b %Y'})
    prior_months.each { |mon|
      short_mon = DateTime.parse(mon).strftime('%b')
      total_sales = 0
      self.images.unflagged.each { |img| total_sales += Sales.new(img).total_image_sales(mon) }
      result << { :month => short_mon, :sales => total_sales }
    }
    result
  end

  def total_sales(image_paging_params = {})
    result = {:total_entries => 0, :data => []}
    line_items = sold_items.paginate_and_sort(image_paging_params)
    array = []
    line_items.each { |item|
      info = item
      sale = Sales.new(item.image)
      info.total_sale = sale.total_image_sales
      info.quantity_sale = sale.sold_image_quantity
      info.no_longer_avai = (item.image.flagged? || item.image.removed?)
      array << {:item => info }
    }
    result[:data] = array
    result[:total_entries] = line_items.total_entries
    result
  end

  def images_pageview
    if !self.attributes.has_key?('images_pageview')
      self.attributes['images_pageview'] = self.images.unflagged.sum(:pageview)
    else
      self.attributes['images_pageview'].to_i
    end
  end

  def ban!
    transaction do
      self.banned = true
      save!
      UserMailer.delay.banned_user_email(id)
    end
  end

  def remove!
    unless removed?
      transaction do
        images.not_removed.update_all(removed: true)
        self.removed = true
        save!
        UserMailer.delay.removed_user_email(id)
      end
    end
  end

  def remove_flagged_images
    self.images.flagged.update_all(:removed => true)
  end

  def reinstate
    if !self.ready_for_reinstating?
      return false#raise NotReadyForReinstatingError
    end

    self.class.transaction do
      if self.banned?
        self.update_attribute(:banned, false)
        UserMailer.delay.reinstated_user_email(id)
      end
    end
  end

  def reinstate_flagged_images
    Image.transaction do
      self.images.flagged.each do |image|
        image.reinstate!
      end
    end
  end

  def ban_threshold_met?
    !banned? && !ready_for_reinstating?
  end

  def ready_for_reinstating?
    images.flagged.length < MIN_FLAGGED_IMAGES
  end

  def blocked?
    banned? || removed?
  end

  def total_earn
    result = 0
    items = self.images
    items.each {|item| result += Sales.new(item).total_image_sales }
    result
  end

  def owned_amount
    self.total_earn - withdrawn_amount
  end

  def withdraw_paypal(amount)
    if (self.paypal_email.blank?)
      errors.add(:paypal_email, "must exist")
      return false
    elsif (amount > owned_amount)
      errors.add(:base, "Amount must be less than owned amount")
      return false
    elsif (amount <= 0)
      errors.add(:base, "Amount not valid")
      return false
    else
      # PAYPAL WITHDRAW HERE
      paypal_result = Payment.transfer_balance_via_paypal(amount, self.paypal_email)
      if paypal_result.success?
        self.increment!(:withdrawn_amount, amount)
        return true
      else
        errors.add(:base, 'Sorry! Something went wrong while processing your commission, please check back later.')
        ExternalLogger.new.log_error(paypal_result, paypal_result.message, paypal_result.params)
        return false
      end
    end
  end

  def owns_image?(image)
    image.user_id == id
  end

  def owns_gallery?(gallery)
    gallery.user_id == id
  end

  # TODO: move into ability class
  def can_access?(gallery)
    owns_gallery?(gallery) || gallery.permission.public? || GalleryInvitation.find_by_user_id(id).present?
  end

  def like_image(image, image_url=nil)
    User.delay.facebook_like(self.id, image_url) unless image.liked_by?(self)
    image_likes.create(image_id: image.id) unless image.liked_by?(self)
    { image_likes_count: image.reload.image_likes.size }
  end

  def unlike_image(image)
    image_likes.where(image_id: image.id).first.destroy if image.liked_by?(self)
    { image_likes_count: image.reload.image_likes.size }
  end

  def confirm!
    UserMailer.deliver_welcome_email(self).deliver
    super
  end

  def apply_omniauth(omniauth)
    self.email = omniauth.info.email if email.blank?
    self.username = omniauth.info.nickname if username.blank?
    self.confirmed_at = Time.now.utc
    if omniauth.provider == "twitter"
      name = omniauth.info.name.split(' ')
      self.first_name = name.first
      self.last_name = name.last
    elsif omniauth.provider == "facebook"
      self.first_name = omniauth.info.first_name
      self.last_name = omniauth.info.last_name
    end
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'], :oauth_token => omniauth['credentials']['token'], :oauth_secret => omniauth['credentials']['secret'])
  end

  def password_required?
    (authentications.empty? || !password.blank?) && super
  end

  def facebook
    auth = authentications.where("provider = ?", "facebook").first
    if auth
    @facebook ||= Koala::Facebook::API.new(auth.oauth_token)
    block_given? ? yield(@facebook) : @facebook
    end
  end

  def self.facebook_upload(user_id, image_url)
    user = User.find(user_id)
    if user.authentications.where("provider = ?", "facebook").any?
      user.facebook.put_connections("me", "uploapp:upload", photo: image_url)
    end
  rescue Exception => e
    nil
  end

  def self.twitter_upload(user_id, image_url)
    user = User.find(user_id)
    if user.authentications.where("provider = ?", "twitter").any?
      user.twitter.update("Uploaded a photo: " + image_url + " on Uplo")
    end
  rescue Exception => e
    nil
  end

  def self.facebook_like(user_id, image_url)
    user = User.find(user_id)
    if user.authentications.where("provider = ?", "facebook").any?
      user.facebook.put_connections("me", "og.likes", object: image_url)
    end
  rescue Exception => e
    nil
  end

  def self.twitter_like(user_id, image_url)
    user = User.find(user_id)
    if user.authentications.where("provider = ?", "twitter").any?
      user.twitter.update("Liked a photo: " + image_url + " on Uplo")
    end
  rescue Exception => e
    nil
  end

  def twitter
    auth = authentications.where("provider = ?", "twitter").first
    if auth
    @twitter ||= Twitter::Client.new(consumer_key: ENV["TWITTER_CONSUMER_KEY"], consumer_secret: ENV["TWITTER_CONSUMER_SECRET"], oauth_token: auth.oauth_token, oauth_token_secret: auth.oauth_secret)
    block_given? ? yield(@twitter) : @twitter

    end
  end

  def device_tokens
    devices.pluck(:device_token)
  end

  def name_for_notification
    if admin?
      "UPLO"
    else
      fullname
    end
  end

  def billing_address_attributes=(options)
    options.delete(:id)
    (self.billing_address || self.build_billing_address).update_attributes(options)
  end

  def shipping_address_attributes=(options)
    options.delete(:id)
    (self.shipping_address || self.build_shipping_address).update_attributes(options)
  end

  def notify?(type)
    self.user_notification.send(type)
  end

  private

    def check_password?
      (!self.force_submit && self.password_required?)
    end

    def scrub_sensitive_fields
      self.cvv = nil
      self.expiration = nil
    end
end
