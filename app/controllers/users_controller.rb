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
    if request.xhr?
      user = User.find_by_id params[:user_id].to_i
      if user.nil?
        result = { :success => false, :msg => 'This user does not exist.' }
      else
        if user.update_attribute('avatar', params[:user][:avatar])
          result = {:success => true}
        else
          result = { :success => false, :msg => user.errors.full_messages[0] }
        end
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

  protected
  def default_page_size
    return 12
  end
end
