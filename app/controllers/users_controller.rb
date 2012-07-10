class UsersController < ApplicationController
  before_filter :authenticate_user!

  def profile
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    respond_to do |format|
      if @user.update_profile(params[:user])
        format.html { redirect_to("/my_account", :notice => I18n.t('user.update_done')) }
      else
        format.html { render :action => "edit", :notice => @user.errors}
      end
    end
  end

  def update_avatar
    avatar = ProfileImage.new({ :user_id => current_user.id,
                                :data => params[:user][:avatar],
                                :last_used => Time.now })
    if current_user.profile_images << avatar
      profile_photos = render_to_string :partial => 'profiles/profile_photos',
             :locals => {:profile_images => current_user.profile_images}
      str = profile_photos.gsub('"', '\'').gsub(/\n/, '')
      result = {:success => true, :profile_photos => profile_photos,
                :extra_avatar_url => current_user.avatar_url(:extra),
                :large_avatar_url => current_user.avatar_url(:large)}
    else
      result = { :success => false, :msg => current_user.errors.full_messages[0] }
    end
    render :json => result, :content_type => 'text/plain'
  end

  def update_profile_info
    if request.xhr?
      if current_user.update_profile(params[:user])
        result = {:success => true, :fullname => current_user.fullname.truncate(18)}
      else
        result = {:success => false, :msg => current_user.errors.full_messages.join(' and ') }
      end
      render :json => result
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
          result = { :success => true, :extra_avatar_url => current_user.avatar_url(:extra), :large_avatar_url => current_user.avatar_url(:large) }
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
    user = User.find_by_id params[:user_id]
    follower = current_user
    if user.id == follower.id
      result[:msg] = 'You cannot follow yourself'
      result[:success] = false
    elsif SharedMethods::Converter.Boolean(params[:unfollow])
      UserFollow.destroy_all({ :user_id => user.id, :followed_by => follower.id })
      result[:followers] = current_user.followers.length
      result[:followings] = current_user.followed_users.length
      result[:success] = true
    elsif UserFollow.exists?({ :user_id => user.id, :followed_by => follower.id })
      result[:msg] = 'You have already followed this user.'
      result[:success] = false
    else
      UserFollow.create({ :user_id => user.id, :followed_by => follower.id })
      result[:followers] = current_user.followers.length
      result[:followings] = current_user.followed_users.length
      result[:success] = true
    end
    render :json => result
  end

  def unlike_image
    image = Image.find_by_id(params[:image_id])
    if image.nil?
      result = { :success => false, :msg => "This image does not exist anymore!" }
    else
      result = image.disliked_by_user(current_user.id)
      result[:likes] = current_user.liked_images.count if result[:success]
    end

    render :json => result
  end

  protected
  def default_page_size
    return 12
  end
end
