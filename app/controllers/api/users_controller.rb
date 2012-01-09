class Api::UsersController < Api::BaseController
  include Devise::Controllers::InternalHelpers
  
  before_filter :authenticate_user!, :except => [:login]
  
  def get_user_info
    @result[:success] = false
    user = User.find_by_id(params[:id])
    if user.nil?
      @result[:msg] = "This user does not exist"
    else
      info = user.serializable_hash(user.default_serializable_options)
      # TODO: rename :avatar to :avatar_url and put it into User#exposed_methods
      info[:avatar] = user.avatar.url
      @result[:user_info] = info
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
    
    unless user.save
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
    if params.blank?
      @result[:success] = false
      @result[:msg] = I18n.t("common.invalid_params")
    elsif @user.update_profile(params)
      @result[:success] = true
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
    
    info = user.serializable_hash(user.default_serializable_options)
    info[:avatar] = user.avatar.url
    @result[:user_info] = info
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
end
