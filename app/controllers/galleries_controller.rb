class GalleriesController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:public]
  skip_authorize_resource :only => [:public]

  before_filter :show_notification

  def index
    @galleries = current_user.galleries.with_images.paginate_and_sort(filtered_params)
    @gallery_invitations = current_user.gallery_invitations.includes(:gallery)
    @gallery = Gallery.new
  end

  def public
    @gallery = Gallery.find(params[:id])
    @author = @gallery.user
    @images = @gallery.images.popular_with_pagination(filtered_params)
    render :layout => "public"
  end

  def show_public
    user = User.find(params[:author])
    @galleries = user.galleries.public_access.with_images.paginate_and_sort(filtered_params)
    render :action => :index
  end

  def share
    emails = params[:email]['emails'].split(',')
    emails.map { |email| email.strip }

    if emails.length > 0 && SharingMailer.delay.share_gallery_email(params[:id], emails, current_user.id, params[:email]['message'])
      flash[:notice] = "Email sent"
    else
      flash[:warning] = "Could not send the email. Please re-check your information (email, message)."
    end
    redirect_to :action => :index
  end

  def search
    galleries = Gallery.search_scope(params[:query]).paginate_and_sort(filtered_params)
    galleries.each { |g| g.name = g.name.truncate(30) and g.name = g.excerpts.name}
    @galleries = galleries
    @gallery = Gallery.new
    render :action => :index
  end

  def search_public
    if !params.has_key? "user"
      with_condition = {}
    elsif params[:user].nil? or params[:user]==""
      with_condition = {}
    else
      params[:query] = ""
      with_condition = {:user_id => params[:user]}
    end

    @galleries = Gallery.search_scope(params[:query]).paginate_and_sort(filtered_params)
    render :layout => 'application'
  end

  def new
    @gallery = Gallery.new
  end

  def create
    @gallery = current_user.galleries.new(params[:gallery])
    respond_to do |format|
      if @gallery.save
        format.html { redirect_to edit_images_gallery_path(@gallery) }
      else
        hide_notification
        @galleries = current_user.galleries.with_images.paginate_and_sort(filtered_params)
        flash[:error] = @gallery.errors.full_messages.to_sentence
        format.html { render :action => :index}
      end
    end
  end

  def edit
    @gallery = current_user.galleries.find(params[:id])
    render layout: false if request.xhr?
  end

  def edit_images
    if params[:id].nil?
      @gallery = current_user.galleries.first
    elsif !Gallery.exists?({:id => params[:id].to_i, :user_id => current_user.id})
      flash[:error] = "You cannot edit another person's gallery!"
      redirect_to :controller => :galleries, :actions => :index
    else
      @gallery = Gallery.find_by_id params[:id]
    end

    if !@gallery.nil?
      @image = Image.new(id: @gallery.id)
      @images = @gallery.images.paginate_and_sort(filtered_params)

      if request.xhr?
        pagination = render_to_string :partial => 'pagination',
          :locals => {  :source => @images, :params => { :controller => "galleries",
          :action => 'edit_images', :id => @gallery.id }, :classes => 'text left' }
        items = render_to_string :partial => 'galleries/edit_photos',
                                :locals => { :images => @images }
        edit_popup = render_to_string :partial => 'edit_gallery', :layout => 'layouts/popup',
            :locals => { :title => 'Edit Your Gallery Infomation',
            :id => 'edit-gallery-popup', :gallery => @gallery }
        gal_options = self.class.helpers.gallery_options(current_user.id, @gallery.id, true)
        render :json => { :items => items, :pagination => pagination,
          :edit_popup => edit_popup, :gallery_options => gal_options,
          :delete_url => url_for(:action => 'destroy', :id => @gallery.id),
          :upload_url => url_for(:controller => 'images', :action => 'create', :gallery_id => @gallery.id) }
      end
    end
  end

  def update
    @gallery = current_user.galleries.find(params[:id])

    if request.xhr?
      if @gallery.update_attributes(params[:gallery])
        edit_popup = render_to_string :partial => 'edit_gallery', :layout => 'layouts/popup',
          :locals => { :title => 'Edit Your Gallery Infomation',
          :id => 'edit-gallery-popup', :gallery => @gallery }
        gal_number_options = self.class.helpers.gallery_options(current_user.id, @gallery.id, true)
        gal_options = self.class.helpers.gallery_options(current_user.id, @gallery.id, false)
        result = { :success => true, :edit_popup => edit_popup,
          :gal_with_number_options => gal_number_options.gsub(/\n/, ''), :gallery_options => gal_options.gsub(/\n/, '') }
      else
        result = { :success => false, :msg => @gallery.errors.full_messages[0] }
      end
      return render :json => result
    else
      respond_to do |format|
        if @gallery.update_attributes(params[:gallery])
          format.html { redirect_to(gallery_images_path(@gallery), :notice => I18n.t('gallery.update_done')) }
        else
          @galleries = current_user.galleries.with_images.paginate_and_sort(filtered_params)
          format.html { render :action => :index, :notice => @gallery.errors}
        end
      end
    end
  end

  def destroy
    @gallery = current_user.galleries.find(params[:id])
    respond_to do |format|
      if @gallery.destroy
        format.html { redirect_to(galleries_path, :notice => I18n.t("gallery.delete_done")) }
      else
        format.html { redirect_to(galleries_path, :notice => I18n.t("gallery.delete_failed")) }
      end
    end
  end
end
