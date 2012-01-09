class GalleriesController < ApplicationController
  before_filter :authenticate_user!
  
  authorize_resource
  before_filter :find_gallery, :only => [:edit, :update, :destroy]
  
  def index
    @galleries = current_user.galleries.load_galleries(@filtered_params)
    @gallery = Gallery.new
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
    if request.xhr?
      render :layout => false
    end
  end
  
  def update
    respond_to do |format|
      if @gallery.update_attributes(params[:gallery])
        format.html { redirect_to(gallery_images_path(@gallery), :notice => I18n.t('gallery.update_done')) }
      else
        format.html { render :action => "edit", :notice => @gallery.errors}
      end
    end 
  end
  
  def destroy
    respond_to do |format|
      if @gallery.destroy
        format.html { redirect_to(galleries_path, :notice => I18n.t("gallery.delete_done")) }
      else
        format.html { redirect_to(galleries_path, :notice => I18n.t("gallery.delete_failed")) }
      end
    end
  end
  
  protected
  
  def set_current_tab
    @current_tab = "galleries"
  end
  
  def find_gallery
    @gallery = current_user.galleries.find_by_id(params[:id])
  end
end
