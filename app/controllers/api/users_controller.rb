class Api::UsersController < Api::BaseController
  include Devise::Controllers::InternalHelpers

  respond_to :json
  
  skip_before_filter :require_login!, only: [:login, :create_user, :reset_password, :request_invitation]

  # GET /api/user_info
  def get_user_info
    user = current_user
    if user.nil?
      render json: { msg: "This user does not exist" }, status: :bad_request
    else
      render json: user, status: :ok
    end
  end

  # POST /api/request_invitation
  # params: email
  def request_invitation
    invite_request = Invitation.new(params[:email])
    if invite_request.save
      render json: { msg: "Your request has been sent" }, status: :ok
    else
      render json: { msg: invite_request.errors.full_messages[0]}, status: :bad_request
    end
  end

  # POST /api/registration
  # params: user
  def create_user
    info = params[:user]
    profile_image_params = params[:profile_image]
    user = User.new(info)
    user.profile_images.build profile_image_params

    if user.save
      render json: user, status: :created
    else
      render json: { msg: user.errors.full_messages.to_sentence }, status: :bad_request
    end
  end

  # POST /api/update_profile
  # params = {:user => {}}
  def update_profile
    if params[:user].blank?
      render json: { msg: "common.invalid_params" }, status: :bad_request
    elsif current_user.update_profile(params[:user])
      profile_image_params = params[:profile_image]
      if (!profile_image_params.nil?)
        avatar = current_user.profile_images.build(params[:profile_image])
        if avatar.save
          render json: current_user, status: :ok
        else
          msg = []
          key = ['avatar_file_size', 'avatar_content_type']
          avatar.errors.messages.each do |k, v|
            msg << v if key.index(k.to_s)
          end
          if msg.size == 0
            msg = 'Invalid file!'
          else
            msg = msg.join(' and ')
          end
          render json: { msg: msg }, status: :bad_request
        end
      else
        render json: current_user, status: :ok
      end
    else
      render json: { msg: current_user.errors.full_messages.to_sentence }, status: :bad_request
    end
  end

  # POST /api/login
  # params:
  #   username
  #   password
  def login
    user = nil
    pw = params[:password]
    # Sign out if signing in
    signed_in = signed_in?(:user)
    Devise.sign_out_all_scopes ? sign_out : sign_out(:user)
    user = authenticate_user(params[:username], params[:password])

    if user
      sign_in(:user, user)
      if params[:device_token].present?
        device = UserDevice.find_by_device_token params[:device_token].to_s
        if device.nil?
          UserDevice.create({:user_id => user.id, :device_token => params[:device_token].to_s, :last_notified => Time.now()})
          Urbanairship.register_device(params[:device_token].to_s)
        elsif device.user_id!=user.id
          device.update_attribute(:user_id, user.id)
        end
      end
      render json: user, :status => :ok
    else 
      render json: { msg: "Invalid credentials"}, status: :bad_request
    end
  end

  # POST /api/logout
  def logout
    signed_in = signed_in?(:user)
    Devise.sign_out_all_scopes ? sign_out : sign_out(:user)
    render json: { msg: :signed_out }, :status => :ok
  end

  # GET /api/reset_password
  # params: email
  def reset_password
    user = User.find_by_email params[:email].downcase
    if user.nil?
      render json: { msg: "Email does not exist" }, status: :bad_request
    else
      User.send_reset_password_instructions({:email => params[:email]})
      render json: { msg: "Reset instructions sent" }, status: :ok
    end
  end

  # GET /api/total_sales
  def get_total_sales
    user = current_user
    user_sales = user.total_sales(filtered_params)
    render json: user_sales, meta: { total: user_sales[:total_entries] }, status: :ok
  end

  # GET /api/user_followers
  # params: user_id
  def get_followers
    user = User.find_by_id params[:user_id]
    user = current_user if user.nil?
    if user.nil?
      render json: { msg: "This user does not exist" }, status: :bad_request
    else
      followers = user.followers.paginate_and_sort(filtered_params)
      render json: process_followers_info(user.id, followers), status: :ok
    end
  end

  # GET /api/user_followings
  # params: user_id
  def get_followed_users
    user = User.find_by_id params[:user_id]
    if user.nil?
      render json: { msg: "This user does not exist" }, status: :bad_request
    else
      followed_users = user.followed_users.paginate_and_sort(filtered_params)
      render json: process_followed_users_info(user.id, followed_users), status: :ok
    end
  end

  # /api/follow
  # follow: T/F <follow/unfollow user>
  # user_id: <current user will follow this user>
  def set_follow
    user = User.find_by_id params[:user_id]
    follower = current_user
    if user.nil?
      render json: { msg: "This user does not exist" }, status: :bad_request
    elsif user.id == follower.id
      render json: { msg: "You cannot follow yourself" }, status: :bad_request
    elsif !params[:follow].to_bool
      UserFollow.destroy_all({ :user_id => user.id, :followed_by => follower.id })
      render json: { msg: "Follows removed" }, status: :ok
    elsif UserFollow.exists?({ :user_id => user.id, :followed_by => follower.id })
      render json: { msg: "You have already followed this user" }, status: :bad_request
    else
      user_follow = UserFollow.create({ :user_id => user.id, :followed_by => follower.id })
      render json: user_follow, status: :ok
    end
  end

  # /api/check_following
  # user_id: <user to check whether current user's follow it or not>
  def check_following
    user = User.find_by_id(params[:user_id])
    if user.nil?
      render json: { msg: "This user does not exist" }, status: :bad_request
    else
      render json: { check_result: user.has_follower?(current_user.id) }, status: :ok
    end
  end

  # POST /api/get_notification_settings
  def get_notification_settings
    device = UserDevice.find_by_device_token params[:device_token].to_s,
      :conditions => { :user_id => current_user.id }
    if device.nil?
      render json: { msg: "You have to log in on this device first!" }, status: :bad_request
    else
      render json: { data:  {:enable_comments => device.notify_comments,
        :enable_likes => device.notify_likes, :enable_purchases => device.notify_purchases } }, status: :ok
    end
  end

  # POST /api/update_notification_settings
  def update_notification_settings
    device = UserDevice.find_by_device_token params[:device_token].to_s,
      :conditions => { :user_id => current_user.id }
    if device.nil?
      render json: { msg: "You have to log in on this device first!" }, status: :bad_request
    else
      begin
        attrs = {
          :notify_purchases => params[:enable_purchases].to_bool,
          :notify_likes => params[:enable_likes].to_bool,
          :notify_comments => params[:enable_comments].to_bool,
          :last_notified => device.last_notified }
        rescue ArgumentError => e
          render json: { msg: "Accepted values: 0/1, t/f, true/false, y/n, yes/no" }, status: :bad_request
        else
          disable_all = (!attrs[:notify_purchases] && !attrs[:notify_comments] && !attrs[:notify_likes])
          if device.update_attributes(attrs)
            if device.active? && disable_all
              Urbanairship.unregister_device(params[:device_token].to_s)
            elsif !device.active? && !disable_all
              Urbanairship.register_device(params[:device_token].to_s)
            end
            render status: :ok
          else
            render json: { msg: device.errors.full_messages }, status: :bad_request
          end
        end
    end
  end

  # POST /api/check_emails
  # Params
  # emails => JSON ARRAY
  def check_emails
    if (params[:emails])
      parsed_json = ActiveSupport::JSON.decode(params[:emails])
      avai_emails = []
      users = User.find_all_by_email(parsed_json)
      render json: { data: process_followers_info(current_user.id, users) }, status: :ok
    else
      render json: { msg: "No email found" }, status: :bad_request
    end
  end

  # GET /api/payment_info
  # Params
  def get_user_payment_info
    render json: { payment_info: { total_earn: current_user.total_earn, owned_amount: current_user.owned_amount }}, status: :ok
  end

  # GET /api/card_info
  def get_user_card_info
    render json: { card_info: { name_on_card: current_user.name_on_card, card_type: current_user.card_type, 
      card_number: current_user.card_number, expiration: current_user.expiration.present? ? Date.parse(current_user.expiration).strftime("%m/%Y") : '', 
      cvv: current_user.cvv }}, status: :ok
  end

  # GET /api/get_moulding
  def get_moulding
    render json: { moulding: MOULDING, discount: MOULDING_DISCOUNT}, status: :ok
  end

  # POST /api/withdraw
  # Params
  # amount => float
  def withdraw
    amount = params[:amount].to_f
    if (current_user.withdraw_paypal(amount))
      render json: { payment_info: { total_earn: current_user.total_earn, owned_amount: current_user.owned_amount }}, status: :ok
    else
      render json: { msg: current_user.errors.full_messages.to_sentence }, status: :bad_request
    end
  end

  protected

    def process_followers_info(user_id, users)
      result = []
      users.each do |u|
        info = u
        info[:following] = u.has_follower?(user_id)
        info[:followed_by_current_user] = u.has_follower?(current_user.id)
        result << {:user => info}
      end
      result
    end

    def process_followed_users_info(user_id, users)
      result = []
      users.each do |u|
        info = u
        info[:followed_by_current_user] = u.has_follower?(current_user.id)
        result << {:user => info}
      end
      result
    end

    def authenticate_user(username, password)
      user = User.find_for_authentication(:username => username)
      unless user.nil?
        user = user.valid_password?(password) ? user : nil      
      end
      user
    end

end
