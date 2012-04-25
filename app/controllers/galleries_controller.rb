class GalleriesController < ApplicationController
  before_filter :authenticate_user!, :except => [:public]
  skip_authorize_resource :only => [:public]

  def public
    @gallery = Gallery.find_by_id params[:gallery_id]
    @author = @gallery.user
    @images = @gallery.load_popular_images(@filtered_params)
    render :layout => "public"
  end

  def mail_shared_gallery
    emails = params[:email]['emails'].split(',')
    emails.map { |email| email.strip }
    SharingMailer.share_gallery_email(params[:gallery_id], emails, current_user.id, params[:email]['message']).deliver
    redirect_to :action => :index
  end

  def index
    @galleries = current_user.galleries.load_galleries(@filtered_params)
    @gallery = Gallery.new
    render :template => 'galleries/index_new', :layout => 'main'
  end

  def show_public
    user = User.find_by_id params[:author]
    if user.nil?
      flash[:error] = "The author does not exist anymore."
    else
      @galleries = user.galleries.load_popular_galleries(@filtered_params)
    end
    render :action => :index
  end

  def search
    galleries = Gallery.search params[:query], :star => true, :with => {:user_id => current_user.id}, :page => params[:page_id], :per_page => default_page_size
    galleries.each { |g| g.name = g.name.truncate(30) and g.name = g.excerpts.name}
    @galleries = galleries
    @gallery = Gallery.new
    render :action => :index
  end

  def search_public
    if not params.has_key? "user"
      with_condition = {}
    elsif params[:user].nil? or params[:user]==""
      with_condition = {}
    else
      params[:query] = ""
      with_condition = {:user_id => params[:user]}
    end

    @no_async_image_tag = true
    @galleries = Gallery.search params[:query], :star => true, :page => params[:page_id], :per_page => default_page_size, :with => with_condition
  end

  def new
    @gallery = Gallery.new
  end

  def create
    @gallery = current_user.galleries.new(params[:gallery])
    respond_to do |format|
      if @gallery.save
        format.html { redirect_to(gallery_images_path(@gallery), :notice => I18n.t('gallery.create_done')) }
      else
        format.html { render :action => "new", :notice => @gallery.errors}
      end
    end
  end

  def edit
    if find_gallery!
      if request.xhr?
        render :layout => false
      end
    end
  end

  def update
    if find_gallery!
      respond_to do |format|
        if @gallery.update_attributes(params[:gallery])
          format.html { redirect_to(gallery_images_path(@gallery), :notice => I18n.t('gallery.update_done')) }
        else
          format.html { render :action => "edit", :notice => @gallery.errors}
        end
      end
    end
  end

  def destroy
    if find_gallery!
      respond_to do |format|
        if @gallery.destroy
          format.html { redirect_to(galleries_path, :notice => I18n.t("gallery.delete_done")) }
        else
          format.html { redirect_to(galleries_path, :notice => I18n.t("gallery.delete_failed")) }
        end
      end
    end
  end

  protected

  def set_current_tab
    tab = "galleries"

    browse_actions = ["search_public", "show_public"]
    unless browse_actions.index(params[:action]).nil?
      tab = "browse"
    end

    @current_tab = tab
  end

  def default_page_size
    return 12
  end

  def find_gallery
    @gallery = Gallery.find_by_id(params[:id])
  end

  def find_gallery!
    self.find_gallery
    if @gallery.blank?
      render_not_found
      return false
    elsif !@gallery.can_access?(current_user) ||
          (!@gallery.is_owner?(current_user) && %w(edit update destroy).include?(params[:action]))
      render_unauthorized
      return false
    end
    @gallery
  end
end
