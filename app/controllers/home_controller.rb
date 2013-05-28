class HomeController < ApplicationController
  self.per_page = 30

  skip_before_filter :authenticate_user!, :except => [:friends_feed]

  before_filter :accept_gallery_invitation, :only => [:index]

  IMAGE_SORT_VIEW = {
    Image::SORT_OPTIONS[:view] => 'Most Views',
    Image::SORT_OPTIONS[:recent] => 'Recent Uploads',
    Image::SORT_OPTIONS[:spotlight] => 'Spotlight Images'
  }

  USER_SORT_VIEW = {
    User::SORT_OPTIONS[:name] => 'Best Match',
    User::SORT_OPTIONS[:date_joined] => 'Date Joined'  }


  def browse
    @current_views = IMAGE_SORT_VIEW[Image::SORT_OPTIONS[:recent]]
    filtered_params[:sort_direction] = 'desc'
    filtered_params[:sort_field] = "images.created_at"
    @data = Image.public_access.paginate_and_sort(filtered_params)
  end

  def index
    @current_views = IMAGE_SORT_VIEW[Image::SORT_OPTIONS[:spotlight]]
    filtered_params[:sort_direction] = 'desc'
    filtered_params[:sort_field] = "images.created_at"
    @data = Image.spotlight.paginate_and_sort(filtered_params)
    render :template => 'home/browse'
  end

  def terms
    render :layout => params[:nolayout] ? 'blank' : 'main'
  end

  def payment
    render :layout => params[:nolayout] ? 'blank' : 'main'
  end

  def friends_feed
    @images = current_user.friends_images.popular_with_pagination(filtered_params)
  end

  def intro
  end

  def search
    process_search_params
    if params[:filtered_by] == Image::SEARCH_TYPE
      @current_views = IMAGE_SORT_VIEW[params[:sort_by]]
      filtered_params[:sort_direction] = 'DESC'
      case params[:sort_by]
      when "recent"
        filtered_params[:sort_field] = "images.created_at"
      when "views"
        filtered_params[:sort_field] = "images.pageview"
      when "spotlight"
        filtered_params[:sort_field] = "images.promoted"
      end

      @data = Image.search_scope(params[:query]).
                public_or_owner(current_user).
                paginate_and_sort(filtered_params)

    else #filtered by user
      @current_views = USER_SORT_VIEW[params[:sort_by]]
      filtered_params[:sort_criteria] = User::SORT_CRITERIA[params[:sort_by]]
      @data = User.confirmed.search_scope(params[:query]).paginate_and_sort(filtered_params)
    end
    render :template => 'home/browse'
  end

  def require_login
    session[:user_return_to] = request.referrer
    flash[:alert] = "You need to sign in or sign up before continuing."
    redirect_to new_user_session_path
  end

  protected

    def process_search_params
      params[:filtered_by] = Image::SEARCH_TYPE if params[:filtered_by].blank?
      if params[:filtered_by] == Image::SEARCH_TYPE
        params[:sort_by] = Image::SORT_OPTIONS[:recent] if params[:sort_by].blank? || !Image::SORT_OPTIONS.has_value?(params[:sort_by])
      else #filtered by user
        params[:sort_by] = User::SORT_OPTIONS[:name] if params[:sort_by].blank?|| !User::SORT_OPTIONS.has_value?(params[:sort_by])
      end
    end

    def accept_gallery_invitation
      if current_user && session[:gallery_invitation_id].present?
        gallery_invitation = GalleryInvitation.find_by_id(session[:gallery_invitation_id])
        session[:gallery_invitation_id] = nil
        gallery_invitation.update_attributes(:user_id => current_user.id, :secret_token => nil) if gallery_invitation
        return redirect_to gallery_images_path(gallery_invitation.gallery)
      end
    end

end
