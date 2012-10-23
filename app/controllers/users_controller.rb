class UsersController < ApplicationController
  include SocialModule
  before_filter :authenticate_user!, :except => [:request_invitation]
  before_filter :show_notification
  layout 'main'
  
  def request_invitation
    if params[:user].nil? || !params[:user].has_key?('email') || params[:user][:email].blank?
      flash[:error] = "Please input an email first"
    elsif (User::EMAIL_REG_EXP =~ params[:user][:email]).nil?
      flash[:error] = 'The email is invalid'
    elsif Invitation.exists?(:email => params[:user][:email]) || User.exists?(:email => params[:user][:email])
      flash[:error] = 'The email has been used'
    else
      req = Invitation.new_invitation(params[:user][:email])
      if req.save
        flash[:success] = "Your request has been sent"
      else
        flash[:error] = req.errors.full_messages[0]
      end
    end
    redirect_to :controller => 'home', :action => 'index'
  end

  def profile
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    type_update = params[:user][:type_update]
    params[:user].delete(:type_update)
    if (type_update == "payment_info")
      card_required_info = ['name_on_card', 'card_type', 'card_number', 'expiration(1i)', 'expiration(2i)']

      card_required_info.each { |val|
        if !params[:user].has_key?(val) || params[:user][val].blank?
          error = 'Please fill all required fields first!'
          return render :json => [error], :status => :unprocessable_entity
        end
      }

      expires_on = Date.civil(params[:user]["expiration(1i)"].to_i,
                         params[:user]["expiration(2i)"].to_i, 1)
      params[:expiration] = expires_on.strftime("%m-%Y")
      params[:user].delete "expiration(1i)"
      params[:user].delete "expiration(2i)"
      params[:user].delete "expiration(3i)"
    end
    address = nil
    if (type_update == "billing_address" || type_update == "shipping_address")
      # Update Authorize Net Account
      
      address = @user.billing_address ||= Address.new if (type_update == "billing_address")
      address = @user.shipping_address ||= Address.new if (type_update == "shipping_address")
      
      if (address.update_attributes params[:address])
        params[:user][:billing_address_id] = address.id if (type_update == "billing_address")
        params[:user][:shipping_address_id] = address.id if (type_update == "shipping_address")
      else
        respond_to do |format|
          format.html do
            if request.xhr?
              render :json => address.errors.full_messages, :status => :unprocessable_entity
            else
              redirect_to("/my_account", :notice => address.errors)
            end
          end
        end
        return
      end
    end

    respond_to do |format|
      if @user.update_profile(params[:user])
        puts params
        sign_in @user, :bypass => true
        format.html do
          if request.xhr?
            render :partial => "/users/sections/#{type_update}", :locals => {:user => @user, :address => address}, :layout => false
          else
            redirect_to("/my_account", :notice => I18n.t('user.update_done'))
          end
        end
      else
        format.html do
          if request.xhr?
            render :json => @user.errors.full_messages, :status => :unprocessable_entity
          else
            redirect_to("/my_account", :notice => @user.errors)
          end
        end
      end
    end
  end

  def update_avatar
    avatar = current_user.profile_images.build({:data => params[:user][:avatar], :last_used => Time.now})
    if avatar.save
      profile_photos = render_to_string :partial => 'profiles/profile_photos',
             :locals => {:profile_images => current_user.profile_images}
      str = profile_photos.gsub('"', '\'').gsub(/\n/, '')
      result = {:success => true, :profile_photos => profile_photos,
                :extra_avatar_url => current_user.avatar_url(:extra),
                :large_avatar_url => current_user.avatar_url(:large)}
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
      result = { :success => false, :msg => msg }
    end
    render :json => result, :content_type => 'text/plain'
  end

  def update_profile_info
    if current_user.update_profile(params[:user])
      flash[:notice] = 'Profile was successfully updated.'
      redirect_to :controller => 'profiles', :action => 'show'
    else
      flash[:alert] = current_user.errors.full_messages.to_sentence
      redirect_to  :controller => 'profiles', :action => 'show'
    end
  end

  def delete_profile_photo
    if request.xhr?
      if !ProfileImage.exists?(params[:id])
        profile_photos = render_to_string :partial => 'profiles/profile_photos',
               :locals => {:profile_images => current_user.profile_images}
        result = { :success => true, :profile_photos => profile_photos,
                  :extra_avatar_url => current_user.avatar_url(:extra),
                  :large_avatar_url => current_user.avatar_url(:large) }
      elsif current_user.has_profile_photo?(params[:id])
        begin
          ProfileImage.destroy(params[:id])
          profile_photos = render_to_string :partial => 'profiles/profile_photos',
               :locals => {:profile_images => current_user.profile_images}
          result = { :success => true, :profile_photos => profile_photos,
                    :extra_avatar_url => current_user.avatar_url(:extra),
                    :large_avatar_url => current_user.avatar_url(:large) }
        rescue
          result = {:success => false, :msg => 'Something went wrong!'}
        end
      else
        result = {:success => false, :msg => 'This is not your profile photo!'}
      end
      render :json => result
    end
  end

  def set_avatar
    if request.xhr?
      if current_user.has_profile_photo?(params[:id])
        begin
          ProfileImage.find_by_id(params[:id]).set_as_default
          result = { :success => true, :extra_avatar_url => current_user.avatar_url(:extra),
            :large_avatar_url => current_user.avatar_url(:large) }
        rescue
          result = {:success => false, :msg => 'Something went wrong!'}
        end
      else
        result = {:success => false, :msg => 'This is not your profile photo!'}
      end
      render :json => result
    end
  end

  def search
    @no_async_image_tag = true
    @users = User.search params[:query], :star => true, :page => params[:page_id], :per_page => default_page_size
  end

  def set_current_tab
    tab = "account"
    browse_actions = ["search"]
    unless browse_actions.index(params[:action]).nil?
      tab = "browse"
    end

    @current_tab = tab
  end

  # follow: T/F <follow/unfollow user>
  # user_id: <current user will follow this user>
  def set_follow
    result = {}
    user = User.active_users.find_by_id params[:user_id]    
    follower = current_user
    
    if user.blank?
      result[:msg] = I18n.t("user.user_was_banned_or_removed")
      result[:success] = false
    elsif user.id == follower.id
      result[:msg] = 'You cannot follow yourself'
      result[:success] = false
    elsif SharedMethods::Converter.Boolean(params[:unfollow])
      if UserFollow.exists?({ :user_id => user.id, :followed_by => follower.id })
        UserFollow.destroy_all({ :user_id => user.id, :followed_by => follower.id })
        result[:followers] = current_user.followers.length
        result[:followings] = current_user.followed_users.length
        result[:followee_followers] = user.followers.length
        result[:success] = true
      else
        result[:msg] = I18n.t("user.error_already_unfollowed")
        result[:success] = false
      end
    else
      if UserFollow.exists?({ :user_id => user.id, :followed_by => follower.id })
        result[:msg] = I18n.t("user.error_already_followed")
        result[:success] = false
      else
        UserFollow.create({ :user_id => user.id, :followed_by => follower.id })
        result[:followers] = current_user.followers.length
        result[:followings] = current_user.followed_users.length
        result[:followee_followers] = user.followers.length
        result[:success] = true
      end
    end
    render :json => result
  end

  def unlike_image
    image = Image.find_by_id(params[:image_id])
    if image.nil?
      result = { :success => false, :msg => "This image does not exist anymore!" }
    else
      result = image.disliked_by_user(current_user.id)
    end

    render :json => result
  end

  # SOCIAL NETWORK INTEGRATION
  # params
  # type_social
  def enable_social
    get_auth_info
    if (params[:type_social] == "Facebook")
      @api_key = @facebook_cfg["api_key"]
      @secret = @facebook_cfg["secret"]

      oauth_client = OAuth2::Client.new(@api_key, @secret, {
        :authorize_url => 'https://www.facebook.com/dialog/oauth'
      })

      redirect_to oauth_client.authorize_url({
          :client_id => @api_key,
          :redirect_uri => url_for(:controller => :socials, :action => :facebook_callback),
          :scope => "offline_access,publish_stream"
      }) and return
    elsif (params[:type_social] == "Twitter")

      @consumer_key = @twitter_cfg["consumer_key"]
      @consumer_secret = @twitter_cfg["consumer_secret"]
      @options = {:site => "http://api.twitter.com", :request_endpoint => "http://api.twitter.com"}

      consumer = OAuth::Consumer.new(@consumer_key, @consumer_secret, @options)
      request_token = consumer.get_request_token(:oauth_callback => url_for(:controller => :socials, :action => :twitter_callback))

      session[:token]= request_token.token
      session[:secret]= request_token.secret
      redirect_to request_token.authorize_url and return
    elsif (params[:type_social] == "Pinterest")

    elsif (params[:type_social] == "Tumblr")

      @consumer_key = @tumblr_cfg["consumer_key"]
      @consumer_secret = @tumblr_cfg["consumer_secret"]

      consumer=OAuth::Consumer.new( @consumer_key, @consumer_secret, {
        :site => "http://www.tumblr.com",
        :scheme             => :header,
        :http_method        => :post,
        :request_token_path => "/oauth/request_token",
        :access_token_path  => "/oauth/access_token",
        :authorize_path     => "/oauth/authorize"
      })

      request_token=consumer.get_request_token
      session[:request_token]=request_token 
      redirect_to request_token.authorize_url and return

    elsif (params[:type_social] == "Flickr")
      require 'flickraw'

      @api_key = @flickr_cfg["api_key"]
      @secret_key = @flickr_cfg["secret"]

      FlickRaw.api_key=@api_key
      FlickRaw.shared_secret=@secret_key

      request_token = flickr.get_request_token :oauth_callback => url_for(:controller => :socials, :action => :flickr_callback)
      session[:request_token]=request_token 
      redirect_to flickr.get_authorize_url(request_token['oauth_token'], :perms => 'delete') and return

    end

    flash[:notice] = "Not found the social network integration"
    redirect_to :action => :profile
  end

  # params
  # type_social
  def disable_social
    if (params[:type_social] == "Facebook")
      current_user.update_attribute(:facebook_token, "")  
    elsif (params[:type_social] == "Twitter")
      current_user.update_attribute(:twitter_token, "")
    elsif (params[:type_social] == "Pinterest") 
      current_user.update_attribute(:pinterest_token, "")
    elsif (params[:type_social] == "Tumblr")
      current_user.update_attribute(:tumblr_token, "")
    elsif (params[:type_social] == "Flickr")
      current_user.update_attribute(:flickr_token, "")
    end
    flash[:notice] = "Disabled #{params[:type_social]}"
    redirect_to :action => :profile
  end



  protected
  def default_page_size
    return 12
  end
end
