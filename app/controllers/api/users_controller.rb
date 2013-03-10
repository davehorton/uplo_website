class Api::UsersController < Api::BaseController
  include Devise::Controllers::InternalHelpers

  before_filter :require_login!, :except => [:login, :create_user, :reset_password, :request_invitation]

  def get_user_info
    @result[:success] = false
    user = User.find_by_id(params[:id])
    if user.nil?
      @result[:msg] = "This user does not exist"
    else
      @result[:user_info] = init_user_info(user)
      @result[:success] = true
    end
    render :json => @result
  end

  # params: email
  def request_invitation
    @result[:success] = false
    if !params.has_key?('email') || params[:email].blank?
      @result[:msg] = "Please input an email first"
    elsif (User::EMAIL_REG_EXP =~ params[:email]).nil?
      @result[:msg] = 'The email is invalid'
    elsif Invitation.exists?(:email => params[:email]) || User.exists?(:email => params[:email])
      @result[:msg] = 'The email has been used'
    else
      req = Invitation.new_invitation(params[:email])
      if req.save
        @result[:success] = true
        @result[:msg] = "Your request has been sent"
      else
        @result[:msg] = req.errors.full_messages[0]
      end
    end
    render :json => @result
  end

  def create_user
    info = params[:user]
    profile_image_params = params[:profile_image]
    if (!profile_image_params.nil?)
      profile_image_params[:last_used] = Time.now
    end
    user = User.new(info)
    @result = {
      :success => true,
      :msg => {}
    }
    user.profile_images.build profile_image_params
    if user.save
      #@result[:user_info] = init_user_info(user)
    else
      messages = user.errors.full_messages
      if messages.is_a?(Array)
        @result[:msg] = messages.first
      else
        @result[:msg] = messages
      end
      @result[:success] = false
    end
    render :json => @result
  end

  # POST update_profile
  # params = {:user => {}}
  def update_profile
    if params[:user].blank?
      @result[:success] = false
      @result[:msg] = I18n.t("common.invalid_params")
    elsif @user.update_profile(params[:user])
      profile_image_params = params[:profile_image]
      if (!profile_image_params.nil?)
        avatar = @user.profile_images.build({:data => params[:profile_image][:data], :last_used => Time.now})
        if avatar.save
           @result[:success] = true
           @result[:user_info] = init_user_info(@user)
        else
          msg = []
          key = ['data_file_size', 'data_content_type']
          avatar.errors.messages.each do |k, v|
            msg << v if key.index(k.to_s)
          end
          if msg.size == 0
            msg = 'Invalid file!'
          else
            msg = msg.join(' and ')
          end
          @result = { :success => false, :msg => msg }
        end
      else
        @result[:success] = true
        @result[:user_info] = init_user_info(@user)
      end
    else
      @result[:success] = false
      messages = @user.errors.full_messages
      if messages.is_a?(Array)
        @result[:msg] = messages.first
      else
        @result[:msg] = messages
      end
    end

    render :json => @result
  end

  def login
    @result[:success] = false

    # Sign out if signing in
    signed_in = signed_in?(:user)
    Devise.sign_out_all_scopes ? sign_out : sign_out(:user)
    # Modify to apply devise
    user = warden.authenticate!(:api)
    sign_in(:user, user)
    # End of modification

    unless params[:device_token].blank?
      device = UserDevice.find_by_device_token params[:device_token].to_s
      if device.nil?
        UserDevice.create({:user_id => user.id, :device_token => params[:device_token].to_s, :last_notified => Time.now()})
        Urbanairship.register_device(params[:device_token].to_s)
      elsif device.user_id!=user.id
        device.update_attribute(:user_id, user.id)
      end
    end

    @result[:user_info] = init_user_info(user)
    @result[:success] = true
    render :json => @result
  end

  def logout
    @result[:success] = false
    signed_in = signed_in?(:user)
    Devise.sign_out_all_scopes ? sign_out : sign_out(:user)
    if signed_in
      @result[:msg] = :signed_out
      @result[:success] = true
    end
    render :json => @result
  end

  def reset_password
    @result[:success] = true
    user = User.find_by_email params[:email].downcase
    if user.nil?
      @result[:success] = false
      @result[:msg] = "Email does not exist"
    else
      User.send_reset_password_instructions({:email => params[:email]})
    end
    render :json => @result
  end

  def get_total_sales
    user = current_user
    user_sales = user.total_sales(@filtered_params)
    result = {
      :success => true,
      :total => user_sales[:total_entries],
      :data => user_sales[:data]
    }
    render :json => result
  end

  # GET /api/user_followers
  # params: user_id
  def get_followers
    user = User.find_by_id params[:user_id]
    if user.nil?
      result = {:success => false, :msg => 'This user does not exist.'}
    else
      followers = user.followers.load_users(@filtered_params)
      result = {
        :success => true,
        :data => process_followers_info(user.id, followers) }
    end
    render :json => result
  end

  # GET /api/user_followings
  # params: user_id
  def get_followed_users
    user = User.find_by_id params[:user_id]
    if user.nil?
      result = {:success => false, :msg => 'This user does not exist.'}
    else
      followed_users = user.followed_users.load_users(@filtered_params)
      result = {
        :success => true,
        :data => process_followed_users_info(user.id, followed_users) }
    end
    render :json => result
  end

  # /api/follow
  # follow: T/F <follow/unfollow user>
  # user_id: <current user will follow this user>
  def set_follow
    result = {}
    user = User.find_by_id params[:user_id]
    follower = current_user
    if user.nil?
      result = {:success => false, :msg => 'This user does not exist.'}
    elsif user.id == follower.id
      result[:msg] = 'You cannot follow yourself'
      result[:success] = false
    elsif !SharedMethods::Converter.Boolean(params[:follow])
      UserFollow.destroy_all({ :user_id => user.id, :followed_by => follower.id })
      result[:success] = true
    elsif UserFollow.exists?({ :user_id => user.id, :followed_by => follower.id })
      result[:msg] = 'You have already followed this user.'
      result[:success] = false
    else
      UserFollow.create({ :user_id => user.id, :followed_by => follower.id })
      result[:success] = true
    end
    render :json => result
  end

  # /api/check_following
  # user_id: <user to check whether current user's follow it or not>
  def check_following
    result = {}
    user = User.find_by_id params[:user_id]
    if user.nil?
      result = {:success => false, :msg => 'This user does not exist.'}
    else
      result = {:success => true, :check_result => user.has_follower?(current_user.id)}
    end
    render :json => result
  end

  def get_notification_settings
    device = UserDevice.find_by_device_token params[:device_token].to_s,
      :conditions => { :user_id => current_user.id }
    if device.nil?
      result = { :success => false, :msg => 'You have to log in on this device first!' }
    else
      result = { :success => true, :data => { :enable_comments => device.notify_comments,
        :enable_likes => device.notify_likes, :enable_purchases => device.notify_purchases }}
    end
    render :json => result
  end

  def update_notification_settings
    device = UserDevice.find_by_device_token params[:device_token].to_s,
      :conditions => { :user_id => current_user.id }
    if device.nil?
      result = { :success => false, :msg => 'You have to log in on this device first!' }
    else
      begin
        attrs = {
          :notify_purchases => SharedMethods::Converter.Boolean(params[:enable_purchases]),
          :notify_likes => SharedMethods::Converter.Boolean(params[:enable_likes]),
          :notify_comments => SharedMethods::Converter.Boolean(params[:enable_comments]),
          :last_notified => device.last_notified }
        rescue ArgumentError => e
          result = { :success => false, :msg => 'Please make sure your setting values is Boolean (0/1, t/f, true/false, y/n, yes/no)!' }
        else
          disable_all = (!attrs[:notify_purchases] && !attrs[:notify_comments] && !attrs[:notify_likes])
          if device.update_attributes(attrs)
            if device.active? && disable_all
              Urbanairship.unregister_device(params[:device_token].to_s)
            elsif !device.active? && !disable_all
              Urbanairship.register_device(params[:device_token].to_s)
            end
            result = { :success => true }
          else
            result = { :success => false, :msg => device.errors.full_messages}
          end
        end
    end
    render :json => result
  end

  # POST /api/check_emails
  # Params
  # emails => JSON ARRAY

  def check_emails
    result = { :success => false, :msg => "", :emails => []}
    if (params[:emails])
      parsed_json = ActiveSupport::JSON.decode(params[:emails])
      avai_emails = []
      users = User.find_all_by_email(parsed_json)
      result = { :success => true, :data => process_followers_info(current_user.id, users)}
    else
      result = { :success => false, :msg => "No email found", :emails => []}
    end
    render :json => result
  end

  # GET /api/payment_info
  # Params
  #

  def get_user_payment_info
    result = { :success => true, :msg => "", :payment_info => {}}
    result[:payment_info][:total_earn] = current_user.total_earn
    result[:payment_info][:owned_amount] = current_user.owned_amount
    render :json => result
  end

  def get_user_card_info
    result = { :success => true, :msg => "", :card_info => {}}
    result[:card_info][:name_on_card] = current_user.name_on_card
    result[:card_info][:card_type] = current_user.card_type
    result[:card_info][:card_number] = current_user.card_number
    result[:card_info][:expiration] = Date.parse(current_user.expiration).strftime("%m/%Y")
    result[:card_info][:cvv] = current_user.cvv
    render :json => result
  end

  def get_moulding
    result = { :success => true, :msg => "", :moulding => Image::MOULDING, :discount => Image::MOULDING_DISCOUNT}
    render :json => result
  end

  # POST /api/withdraw
  # Params
  # amount => float

  def withdraw
    result = { :success => false, :msg => "", :payment_info => {}}
    amount = params[:amount].to_f

    if (@user.withdraw_paypal amount)
      result[:success] = true
    else
      result[:msg] = @user.errors.full_messages.to_sentence
    end
    result[:payment_info][:total_earn] = @user.total_earn
    result[:payment_info][:owned_amount] = @user.owned_amount
    render :json => result
  end

  protected
    # Init a hash containing user's info
    def init_user_info(user)
      user.confirmed_at = Time.now
      info = user.serializable_hash(user.default_serializable_options)
      # TODO: rename :avatar to :avatar_url and put it into User#exposed_methods
      info[:avatar_url] = user.avatar_url(:thumb)
      if user.id == current_user.id
        info[:galleries_num] = user.galleries.size
        info[:images_num] = user.images.unflagged.size
      else
        info[:galleries_num] = user.public_galleries.size
        info[:images_num] = user.images.visible_everyone.size
      end

      info[:followers_num] = user.followers.size
      info[:following_num] = user.followed_users.size
      info[:tiers] = Image::TIERS_PRICES

      if params[:action] == 'login'
        info[:cart_items_num] = (user.cart.nil? || user.cart.order.nil?) ? 0 : user.cart.order.line_items.count
      end

      return info
    end

    def process_followers_info(user_id, users)
      result = []
      user = User.find_by_id user_id
      users.each { |u|
        info = u.serializable_hash(u.default_serializable_options)
        info[:following] = u.has_follower?(user.id)
        info[:followed_by_current_user] = u.has_follower?(current_user.id)
        result << {:user => info}
      }
      return result
    end

    def process_followed_users_info(user_id, users)
      result = []
      user = User.find_by_id user_id
      users.each { |u|
        info = u.serializable_hash(u.default_serializable_options)
        info[:followed_by_current_user] = u.has_follower?(current_user.id)
        result << {:user => info}
      }
      return result
    end
end
