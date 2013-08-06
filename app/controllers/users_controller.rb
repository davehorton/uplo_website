class UsersController < ApplicationController
  self.per_page = 12
  before_filter :show_notification
  respond_to :json

  def update
    type_update = params[:type_update]

    respond_to do |format|
      if current_user.update_profile(params[:user], type_update)
        sign_in current_user, :bypass => true
        format.html do
          if request.xhr?
            render(partial: "/users/sections/#{type_update}", layout: false)
          else
            redirect_to("/my_account", :notice => I18n.t('user.update_done'))
          end
        end
      else
        format.html do
          if request.xhr?
            render :json => current_user.errors.full_messages, :status => :unprocessable_entity
          else
            redirect_to("/my_account", :notice => current_user.errors)
          end
        end
      end
    end
  end
  
  
  def update_avatar
    avatar = current_user.profile_images.build(:avatar => params[:user][:avatar])
    if avatar.save
      profile_photos = render_to_string :partial => 'profiles/profile_photos',
             :locals => {:profile_images => current_user.profile_images}
      str = profile_photos.gsub('"', '\'').gsub(/\n/, '')
      result = {:success => true, :profile_photos => profile_photos,
                :extra_avatar_url => current_user.avatar_url(:extra),
                :large_avatar_url => current_user.avatar_url(:large)}
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
      result = { :success => false, :msg => msg }
    end
    render :json => result, :content_type => 'text/plain'
  end

  def update_profile_info
    if current_user.update_profile(params[:user])
      flash[:notice] = 'Profile was successfully updated.'
      redirect_to profile_path
    else
      flash[:alert] = current_user.errors.full_messages.to_sentence
      redirect_to profile_path
    end
  end
  def testpush
   message = "#your image"
       tokens = ['6DB667D3B507408892B8CF891A9DB00B388BF8F7B95E1C1C9C3DADF67F2C70BD']
        notification = {
          :schedule_for => [30.second.from_now],
          :device_tokens => tokens,
          :aps => { :alert => message },
          :data => { :type => 'like', :id => '1' }
        }
        Urbanairship.push(notification)
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
    profile_image = current_user.profile_images.find(params[:id])
    profile_image.set_as_default
    render json: {
      success: true,
      extra_avatar_url: current_user.avatar_url(:extra),
      large_avatar_url: current_user.avatar_url(:large)
    }
  rescue Exception => ex
    ExternalLogger.new.log_error(ex, "Problem setting avatar", params)
    render json: { success: false, msg: "Something went wrong" }
  end

  def search
    @users = User.search_scope(params[:query]).paginate_and_sort(filtered_params)
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
    user = User.find(params[:user_id])

    follower = current_user
    if user.blank?
      result[:msg] = I18n.t("user.user_was_banned_or_removed")
      result[:success] = false
    elsif user.id == follower.id
      result[:msg] = 'You cannot follow yourself'
      result[:success] = false
    elsif params[:unfollow].to_bool
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
              	  			Rails.logger.debug 'bas is the best'

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
      result = current_user.unlike_image(image)
    end

    render :json => result
  end

  # SOCIAL NETWORK INTEGRATION
  # params
  # type_social
  def enable_social
    if (params[:type_social] == "Facebook")
      @api_key = FACEBOOK_CONFIG["api_key"]
      @secret = FACEBOOK_CONFIG["secret"]

      oauth_client = OAuth2::Client.new(@api_key, @secret, {
        :authorize_url => 'https://www.facebook.com/dialog/oauth'
      })
      redirect_to oauth_client.authorize_url({
          :client_id => @api_key,
          :redirect_uri => url_for(:controller => :socials, :action => :facebook_callback),
          :scope => "offline_access,publish_stream"
      }) and return
    elsif (params[:type_social] == "Twitter")

      @consumer_key = TWITTER_CONFIG["consumer_key"]
      @consumer_secret = TWITTER_CONFIG["consumer_secret"]
      @options = {:site => "https://api.twitter.com", :request_endpoint => "https://api.twitter.com"}

      consumer = OAuth::Consumer.new(@consumer_key, @consumer_secret, @options)
      request_token = consumer.get_request_token(:oauth_callback => url_for(:controller => :socials, :action => :twitter_callback))

      session[:token]= request_token.token
      session[:secret]= request_token.secret
      redirect_to request_token.authorize_url and return
    elsif (params[:type_social] == "Pinterest")

    elsif (params[:type_social] == "Tumblr")

      @consumer_key = TUMBLR_CONFIG["consumer_key"]
      @consumer_secret = TUMBLR_CONFIG["consumer_secret"]

      consumer = OAuth::Consumer.new( @consumer_key, @consumer_secret, {
        :site => "http://www.tumblr.com",
        :scheme             => :header,
        :http_method        => :post,
        :request_token_path => "/oauth/request_token",
        :access_token_path  => "/oauth/access_token",
        :authorize_path     => "/oauth/authorize"
      })

      request_token = consumer.get_request_token(:oauth_callback => url_for(:controller => :socials, :action => :tumblr_callback))
      session[:request_token] = request_token
      redirect_to request_token.authorize_url and return

    elsif (params[:type_social] == "Flickr")
      require 'flickraw'

      @api_key = FLICKR_CONFIG["api_key"]
      @secret_key = FLICKR_CONFIG["secret"]

      FlickRaw.api_key=@api_key
      FlickRaw.shared_secret=@secret_key

      request_token = flickr.get_request_token :oauth_callback => url_for(:controller => :socials, :action => :flickr_callback)
      session[:request_token]=request_token
      redirect_to flickr.get_authorize_url(request_token['oauth_token'], :perms => 'delete') and return

    end

    flash[:notice] = "Problem enabling social connection"
    redirect_to :action => :account
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
    redirect_to :action => :account
  end

  def account
    @user = current_user if current_user
    @authentications = current_user.authentications if current_user
    twitter = @authentications.where("provider = ?", "twitter")
    facebook = @authentications.where("provider = ?", "facebook")
    @twitter_any = twitter.any?
    @facebook_any = facebook.any?
    @twitter = twitter.first
    @facebook = facebook.first
  end

end
