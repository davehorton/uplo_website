class Api::UsersController < Api::BaseController
  include Devise::Controllers::InternalHelpers

  before_filter :require_login!, :except => [:login, :create_user]

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

  def create_user
    info = params[:user]
    user = User.new(info)
    @result = {
      :success => true,
      :msg => {}
    }

    if user.save
      @result[:user_info] = init_user_info(user)
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
      @result[:success] = true
      @result[:user_info] = init_user_info(@user)
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
    user = User.find_by_email params[:email]
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
      followers.map {|f| f}
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
      result = {
        :success => true,
        :data => user.followed_users.load_users(@filtered_params) }
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

  protected
  # Init a hash containing user's info
  def init_user_info(user)
    info = user.serializable_hash(user.default_serializable_options)
    # TODO: rename :avatar to :avatar_url and put it into User#exposed_methods
    info[:avatar_url] = user.avatar_url
    info[:followers_num] = user.followers.size
    info[:following_num] = user.followed_users.size
    info[:galleries_num] = user.galleries.size
    info[:images_num] = user.images.size

    return info
  end

  def process_followers_info(user_id, users)
    result = []
    user = User.find_by_id user_id
    users.each { |u|
      info = u.serializable_hash(u.default_serializable_options)
      info[:is_following] = u.has_follower?(user.id)
      result << {:user => info}
    }
    return result
  end
end
