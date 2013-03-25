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

  has_many :profile_images, :dependent => :destroy, :order => 'updated_at DESC'
  has_many :galleries, :dependent => :destroy
  has_many :images
  has_many :public_galleries, class_name: 'Gallery', conditions: { permission: Permission::Public.new.to_s }
  has_many :public_images, :through => :public_galleries, :source => :images
  has_many :comments, :dependent => :destroy
  has_many :image_likes, :dependent => :destroy
  has_many :source_liked_images, :through => :image_likes, :source => :image
  has_many :orders
  has_many :devices, :class_name => 'UserDevice'
  has_many :user_followers, :foreign_key => :user_id, :class_name => 'UserFollow'
  has_many :followers, :through => :user_followers
  has_many :user_followings, :foreign_key => :followed_by, :class_name => 'UserFollow'
  has_many :followed_users, :through => :user_followings
  has_many :friends_images, :through => :followed_users, :source => :images
  has_one  :cart, :dependent => :destroy

  belongs_to :billing_address,  :class_name => "Address"
  belongs_to :shipping_address, :class_name => "Address"

  accepts_nested_attributes_for :billing_address
  accepts_nested_attributes_for :shipping_address

  validates_presence_of :first_name, :last_name, :username, :message => 'cannot be blank'
  validates :password, :presence => true, :confirmation => true, :if => :check_password?
  validates_format_of :website, :allow_blank => true,
          :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
  validates_uniqueness_of :username, :message => 'is taken. Choose another one.'

  validates_length_of :first_name, :in => 1..30
  validates_length_of :last_name,  :in => 1..30
  validates_confirmation_of :paypal_email, :message => "should match confirmation"

  validates_length_of :cvv, :in => 3..4, :allow_nil => true
  validates_numericality_of :cvv, :card_number, :only_integer => true, :allow_nil => true
  validate :check_card_number, :if => :card_number_changed?

  validates_presence_of :paypal_email_confirmation, :if => :paypal_email_changed?
  validates :paypal_email, :email => true, :if => :paypal_email_changed?

  default_scope where(removed: false, banned: false).order('users.username asc')

  scope :not_removed,   where(removed: false)
  scope :removed_users, where(removed: true)
  scope :flagged_users, not_removed.where(banned: true)
  scope :confirmed_users, not_removed.where("confirmed_at IS NOT NULL")

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
      AND galleries_data.flagged_images_count < ?",
      MIN_FLAGGED_IMAGES])
    ).select("DISTINCT users.*, galleries_data.flagged_images_count")

  def self.search_scope(query)
    users = User.scoped
    if query.present?
      query = query.gsub(/[[:punct:]]/, ' ').squish
      users = users.advanced_search_by_first_name_or_last_name_or_username_or_email(query, query, query, query)
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
    av = avatar
    if av.nil?
      url = "/assets/avatar-default-#{style.to_s}.jpg"
    else
      url = av.url(style.to_sym)
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
      date = DateTime.strptime(String, I18n.t("date.formats.default"))
      date = date.to_date if date
    end
    self[:birthday] = date
  end

  def update_profile(params)
    result = nil
    params ||= {}
    params.to_options!
    [:username].each do |key|
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
    empty_order = self.orders.where(:status => Order::STATUS[:shopping]).order("orders.created_at DESC").first
    if empty_order.blank?
      empty_order = self.orders.create(:status => Order::STATUS[:shopping])
    end
    empty_order
  end

  def init_cart
    if cart.nil?
      new_order = recent_empty_order
      new_cart = create_cart(:order => new_order)
    elsif cart.order.nil?
      cart.order = recent_empty_order
      cart.save
    end

    if !cart.order.billing_address
      if billing_address
        cart.order.billing_address = billing_address.dup
        cart.order.billing_address.save
      end

      if shipping_address
        cart.order.shipping_address = shipping_address.dup
        cart.order.shipping_address.save
      end

      cart.order.name_on_card = name_on_card
      cart.order.card_type = card_type
      cart.order.card_number = card_number
      cart.order.expiration = expiration
      cart.order.cvv = cvv
      cart.order.save
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
      :conditions => ['orders.user_id=? and orders.transaction_status=?',
        self.id, Order::TRANSACTION_STATUS[:complete]]
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

  #===============================================================================
  # Description:
  # - get saled ($) and saled quantity of each images
  # - sort by highest sold ($)
  # Note:
  #===============================================================================
  def raw_sales(paging_params = {})
    Image.paginate(
      :page => (paging_params[:page] || 1),
      :per_page => paging_params[:per_page],
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
      self.images.unflagged.each { |img| total_sales += img.total_sales(mon) }
      result << { :month => short_mon, :sales => total_sales }
    }
    result
  end

  def total_sales(image_paging_params = {})
    result = {:total_entries => 0, :data => []}
    images = raw_sales(image_paging_params)
    array = []
    images.each { |img|
      info = img
      info[:total_sale] = img.total_sales
      info[:quantity_sale] = img.sold_quantity
      info[:no_longer_avai] = (img.flagged? || img.removed?)
      array << {:image => info }
    }
    result[:data] = array
    result[:total_entries] = images.total_entries
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
    items.each {|item| result += item.total_sales }
    result
  end

  def owned_amount
    self.total_earn - withdrawn_amount
  end

  def withdraw_paypal(amount)
    if (self.paypal_email.blank?)
      errors.add(:paypal_email, "must be exists")
      return false
    elsif (amount > owned_amount)
      errors.add(:base, "The owed amount is not enough")
      return false
    elsif (amount <= 0)
      errors.add(:base, "Amount not valid")
      return false
    else
      # PAYPAL WITHDRAW HERE
      paypal_result = Payment.transfer_ballance_via_paypal amount, self.paypal_email
      if paypal_result.success?
        self.increment!(:withdrawn_amount, amount)
        return true
      else
        errors.add(:base, 'Cannot payout right now! Please try again later!')
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
    owns_gallery?(gallery) || gallery.permission.public?
  end

  def like_image(image)
    image_likes.create(image_id: image.id) unless image.liked_by?(self)
    { likes_count: image.reload.image_likes.size }
  end

  def unlike_image(image)
    image_likes.where(image_id: image.id).first.destroy if image.liked_by?(self)
    { likes_count: image.reload.image_likes.size }
  end

  private

    def check_card_number
      errors.add(:card_number, "is not valid") unless CreditCard.valid_number?(card_number)
    end

    def check_password?
      (!self.force_submit && self.password_required?)
    end
end
