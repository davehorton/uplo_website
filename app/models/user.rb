require 'valid_email'
class User < ActiveRecord::Base
  class NotReadyForReinstatingError < StandardError
  end

  include ::SharedMethods::Paging
  include ::SharedMethods::Converter
  include ::SharedMethods::SerializationConfig

  attr_accessor :force_submit, :login, :skip_state_changed_tracking

  EMAIL_REG_EXP = /^([0-9a-zA-Z]([-.\w]*[0-9a-zA-Z])*@(([0-9a-zA-Z])+([-\w]*[0-9a-zA-Z])*\.)+[a-zA-Z]{2,9})$/i
  GENDER_MALE = "0"
  MIN_FLAGGED_IMAGES = 3
  ALLOCATION_STRING = "#{RESOURCE_LIMIT[:size]} #{RESOURCE_LIMIT[:unit]}"
  ALLOCATION = FileSizeConverter.convert RESOURCE_LIMIT[:size], RESOURCE_LIMIT[:unit], FileSizeConverter::UNITS[:byte]
  FILTER_OPTIONS = ['signup_date', 'username', 'num_of_likes', 'num_of_uploads']
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

  # Setup accessible (or protected) attributes for your model
  attr_accessible :id, :email, :password, :password_confirmation, :remember_me, :twitter_token, :twitter_secret_token, :tumblr_token, :tumblr_secret_token,
                  :first_name, :last_name, :username, :login, :nationality,
                  :birthday, :gender, :avatar, :twitter, :facebook, :website, :biography, :name_on_card,
                  :card_type, :card_number, :expiration, :cvv, :paypal_email, :paypal_email_confirmation,
                  :is_enable_facebook, :is_enable_twitter, :billing_address_id, :shipping_address_id, :job, :location, :shipping_address_attributes, :billing_address_attributes

  attr_accessible :id, :email, :password, :password_confirmation, :remember_me, :twitter_token, :twitter_secret_token, :tumblr_token, :tumblr_secret_token,
                  :first_name, :last_name, :username, :login, :nationality,
                  :birthday, :gender, :avatar, :twitter, :facebook, :website, :biography, :name_on_card,
                  :card_type, :card_number, :expiration, :cvv, :paypal_email, :paypal_email_confirmation,
                  :is_enable_facebook, :is_enable_twitter, :billing_address_id, :shipping_address_id, :job, :location, :shipping_address_attributes, :billing_address_attributes, :is_admin, :as => :admin

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

  has_many :followers,  :through => :user_followers,
                        :conditions => ['users.is_removed = :blocked AND users.is_banned = :blocked',
                                        {:blocked => false}]
  has_many :user_followings, :foreign_key => :followed_by, :class_name => 'UserFollow'
  has_many :followed_users, :through => :user_followings,
                            :conditions => ['users.is_removed = :blocked AND users.is_banned = :blocked',
                                            {:blocked => false}]

  has_many :friends_images, :through => :followed_users, :source => :images
  has_many :devices, :class_name => 'UserDevice'

  belongs_to :billing_address, :class_name => "Address"
  belongs_to :shipping_address, :class_name => "Address"

  # ACCEPT NESTED ATTRIBUTE
  accepts_nested_attributes_for :billing_address
  accepts_nested_attributes_for :shipping_address

  # VALIDATION
  validates_presence_of :first_name, :last_name, :username, :message => 'cannot be blank'
  validates :password, :presence => true, :confirmation => true, :if => :need_checking_password?
  validates_format_of :website, :allow_blank => true,
          :with => /(^$)|(^((http|https):\/\/){1}[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/i
  validates_uniqueness_of :username, :message => 'must be unique'
  validates_length_of :first_name, :last_name, :in => 2..30, :message => 'must be 2 - 30 characters in length'
  validates_confirmation_of :paypal_email, :message => "should match confirmation"
  validates_length_of :cvv, :in => 3..4, :allow_nil => true
  validates_numericality_of :cvv, :card_number, :only_integer => true, :allow_nil => true
  validates_presence_of :paypal_email_confirmation, :if => :paypal_email_changed?
  validates :paypal_email, :email => true, :if => :paypal_email_changed?
  validate :check_card_number

  # SCOPE
  scope :active_users, where(:is_removed => false, :is_banned => false)
  scope :removed_users, where(:is_removed => true)
  scope :flagged_users, where(:is_removed => false, :is_banned => true)

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

  scope :confirmed_users, where("confirmed_at IS NOT NULL AND is_removed = ?", false)

  after_create :cleanup_invitation

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  # CARD VALIDATE
  def check_card_number
    if (card_number)
      unless number_valid? && number_matches_type?
        errors.add(:card_number, "is not a #{readable_card_type} or is invalid")
        return false
      end
    end

    return true
  end

  def readable_card_type
    (@@card_types ||= self.class.card_types.invert)[card_type]
  end

  def digits
    @digits ||= card_number.gsub(/\D/, '')
  end

  def last_digits
    digits.sub(/^([0-9]+)([0-9]{4})$/) { '*' * $1.length + $2 }
  end

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
          params[:sort_field] = 'images_likes_count'
          self.load_users_with_images_statistics(params)
        when 'num_of_uploads' then
          params[:sort_field] = 'images_count'
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

    def card_types
      {"American Express" => "USA_express",
        "Discover" => "discover",
        "Visa" => "visa",
        "JCB" => "jcb",
        "Diners Club/ Carte Blanche" => "dinners_club",
        "Master Card" => "master_card"
      }
    end


    # Load users data with images_likes_count, images_count and images_pageview.
    def load_users_with_images_statistics(params = {})
      paging_info = parse_paging_options(params)

      self.joins(self.sanitize_sql([
        "LEFT JOIN (
          SELECT galleries.user_id,
          SUM(images_data.images_count) AS images_count,
          SUM(images_data.images_likes_count) AS images_likes_count,
          SUM(images_data.images_pageview) AS images_pageview
          FROM galleries LEFT JOIN (
            SELECT gallery_id, COUNT(images.id) AS images_count,
            SUM(likes) AS images_likes_count,
            SUM(pageview) AS images_pageview
            FROM images
            WHERE images.is_removed = :is_removed
            GROUP BY gallery_id
          ) images_data ON galleries.id = images_data.gallery_id
          GROUP BY galleries.user_id
        ) galleries_data
        ON galleries_data.user_id = users.id",
        {:is_removed => false}])
      ).select("DISTINCT users.*,
        COALESCE(galleries_data.images_count, 0) AS images_count,
        COALESCE(galleries_data.images_likes_count, 0) AS images_likes_count,
        COALESCE(galleries_data.images_pageview, 0) AS images_pageview"
      ).paginate(
        :page => paging_info.page_id,
        :per_page => paging_info.page_size,
        :order => paging_info.sort_string
      )
    end

    # Search confirmed user, display banned user or not depend on admin_mod
    def do_search(params = {})
      admin_mod = params[:admin_mod].nil? ? false : params[:admin_mod]
      if admin_mod
        params[:sphinx_search_options] = {
          :with => { :is_removed => false },
          :without => { :date_joined => 'null' }
        }
      else
        params[:sphinx_search_options] = {
          :with => { :is_removed => false, :is_banned => false },
          :without => { :date_joined => 'null' }
        }
      end
      self.search_users(params)
    end

    # Override Devise method so that User can log in with username or email.
    def find_for_database_authentication(warden_conditions)
      conditions = warden_conditions.dup
      login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value",
                              { :value => login.strip.downcase }]).first
    end

    def exposed_methods
      [:avatar_url, :fullname, :joined_date]
    end

    def exposed_attributes
      [:id, :email, :first_name, :biography, :is_enable_facebook, :is_enable_twitter, :location, :paypal_email, :website, :job, :last_name, :username, :nationality, :birthday, :gender, :twitter, :facebook]
    end

    def exposed_associations
      [:billing_address, :shipping_address]
    end

    def remove_flagged_users
      self.transaction do
        self.reinstate_ready_users.each do |user|
          user.remove
        end
      end
    end

    def reinstate_flagged_users
      self.transaction do
        self.reinstate_ready_users.each do |user|
          user.reinstate
        end
      end
    end

    # Get the current user.
    def current_user
      Thread.current[:current_user]
    end

    # Set the current user in this thread.
    def current_user=(user)
      Thread.current[:current_user] = user
    end

    protected
      def parse_paging_options(options, default_opts = {})
        if default_opts.blank?
          default_opts = {
            :sort_criteria => "username DESC"
          }
        end
        paging_options(options, default_opts)
      end
      def search_users(params = {})
        paging_info = parse_paging_options params[:filtered_params]

        sphinx_search_options = params[:sphinx_search_options]
        sphinx_search_options = {} if sphinx_search_options.nil?

        sphinx_search_options.merge!({
          :star => true,
          :retry_stale => true,
          :page => paging_info.page_id,
          :per_page => paging_info.page_size,
          :order => paging_info.sort_string,
          :sort_mode => :extended
        })
        search_term = SharedMethods::Converter::SearchStringConverter.process_special_chars(params[:query])
        User.search search_term, sphinx_search_options
      end
    end

  # PUBLIC INSTANCE METHODS
  def liked_images
    self.source_liked_images.un_flagged.joins('LEFT JOIN galleries ON galleries.id = images.gallery_id').where(
      "galleries.permission = '#{Gallery::PUBLIC_PERMISSION}' OR
      (galleries.permission = '#{Gallery::PRIVATE_PERMISSION}' AND galleries.user_id = #{ self.id })"
    )
  end

  def avatar
    img = ProfileImage.find :first, :conditions => {:user_id => self.id, :default => true}
    if img.nil?
      result = nil
    else
      if img.source && (img.source.is_removed || (img.source.is_flagged?))
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
  def avatar_url(style='thumb')
    avatar = self.avatar
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
    return empty_order
  end

  def init_cart
    if self.cart.nil?
      new_order = self.recent_empty_order
      new_cart = self.create_cart(:order => new_order)
    elsif self.cart.order.nil?
      self.cart.order = self.recent_empty_order
      self.cart.save
    end

    if (!self.cart.order.billing_address)
      if self.billing_address
        self.cart.order.billing_address = self.billing_address.dup
        self.cart.order.billing_address.save
      end
      if self.shipping_address
        self.cart.order.shipping_address = self.shipping_address.dup
        self.cart.order.shipping_address.save
      end

      self.cart.order.name_on_card = self.name_on_card
      self.cart.order.card_type = self.card_type
      self.cart.order.card_number = self.card_number
      self.cart.order.expiration = self.expiration
      self.cart.order.cvv = self.cvv
    end



    return self.cart
  end

  def used_allocation
    total = 0
    self.galleries.each do |gal|
      gal.images.un_flagged.each do |img|
        total += img.data_file_size
      end
    end
    return total
  end

  def free_allocation
    remaining = ALLOCATION
    self.galleries.each do |gal|
      gal.images.un_flagged.each do |img|
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
    prior_months = SharedMethods::TimeCalculator.prior_year_period(date, {:format => '%b %Y'})
    prior_months.each { |mon|
      short_mon = DateTime.parse(mon).strftime('%b')
      total_sales = 0
      self.images.un_flagged.each { |img| total_sales += img.user_total_sales(mon) }
      result << { :month => short_mon, :sales => total_sales }
    }
    return result
  end

  def total_sales(image_paging_params = {})
    result = {:total_entries => 0, :data => []}
    paging_info = Image.paging_options(image_paging_params, {:sort_criteria => "images.updated_at DESC"})
    images = self.raw_sales(image_paging_params)
    array = []
    images.each { |img|
      info = img.serializable_hash(img.default_serializable_options)
      info[:total_sale] = img.user_total_sales
      info[:quantity_sale] = img.saled_quantity
      info[:no_longer_avai] = (img.is_flagged? || img.is_removed)
      array << {:image => info }
    }
    result[:data] = array
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
      self.attributes['images_count'] = self.images.un_flagged.count
    else
      self.attributes['images_count'].to_i
    end
  end

  def images_likes_count
    if !self.attributes.has_key?('images_likes_count')
      self.attributes['images_likes_count'] = self.images.un_flagged.sum(:likes)
    else
      self.attributes['images_likes_count'].to_i
    end
  end

  def images_pageview
    if !self.attributes.has_key?('images_pageview')
      self.attributes['images_pageview'] = self.images.un_flagged.sum(:pageview)
    else
      self.attributes['images_pageview'].to_i
    end
  end

  def get_account_balance

  end

  def remove
    self.class.transaction do
      if !self.is_removed?
        self.update_attribute(:is_removed, true)
        # Send email.
        UserMailer.user_is_removed(self).deliver
      end
    end
  end

  def remove_flagged_images
    self.images.flagged.update_all(:is_removed => true)
  end

  def reinstate
    if !self.ready_for_reinstating?
      raise NotReadyForReinstatingError
    end

    self.class.transaction do
      if self.is_banned?
        self.update_attribute(:is_banned, false)
        # Send email.
        UserMailer.user_is_reinstated(self).deliver
      end
    end
  end

  def reinstate_flagged_images
    Image.transaction do
      self.images.flagged.each do |image|
        image.reinstate
      end
    end
  end

  # Detect if this user is ready for being flagged.
  def will_be_banned?
    (!self.is_banned && !self.ready_for_reinstating?)
  end

  def ready_for_reinstating?
    (self.images.flagged.length < MIN_FLAGGED_IMAGES)
  end

  def is_blocked?
    (self.is_removed || self.is_banned?)
  end

  # USER PAYMENT PROCESSING
  def total_earn
    result = 0
    items = self.images
    items.each {|item| result += item.user_total_sales }
    return result
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

  # AUTHORIZE NET CIM
  def update_user_info_on_authorize_net
    
  end

  protected

    def need_checking_password?
      (!self.force_submit && self.password_required?)
    end

    def cleanup_invitation
      Invitation.destroy_all(:email => self.email)
    end

    def number_valid?
      odd = true
      card_number.gsub(/\D/,'').reverse.split('').map(&:to_i).collect { |d|
        d *= 2 if odd = !odd
        d > 9 ? d - 9 : d
      }.sum % 10 == 0
    end

    def ccTypeCheck(ccNumber)
      ccNumber = ccNumber.gsub(/\D/, '')
      case ccNumber
        when /^3[47]\d{13}$/ then return "USA_express"
        when /^4\d{12}(\d{3})?$/ then return "visa"
        when /^5\d{15}|36\d{14}$/ then return "master_card"
        when /^6011\d{12}|650\d{13}$/ then return "discover"
        when /^3(0[0-5]|8[0-1])\d{11}$/ then return "dinners_club"
        when /^(39\d{12})|(389\d{11})$/ then return "CB"
        when /^3\d{15}|1800\d{11}|2131\d{11}$/ then return "jcb"
        else return "NA"
      end
    end

    def number_matches_type?
      return card_type == ccTypeCheck(card_number)
    end

    # indexing with thinking sphinx
    define_index do
      indexes first_name
      indexes last_name
      indexes username, :sortable => true
      indexes email

      has confirmed_at, :as => :date_joined
      has is_removed
      has is_banned

      if Rails.env.production?
        set_property :delta => FlyingSphinx::DelayedDelta
      else
        set_property :delta => true
      end
    end
end
