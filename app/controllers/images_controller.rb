class ImagesController < ApplicationController
  has_mobile_fu
  before_filter :detect_device
  before_filter :authenticate_user!, :except => [:public]
  skip_authorize_resource :only => :public
  include ::SharedMethods::Converter
  helper :galleries

  def mail_shared_image
    emails = params[:email]['emails'].split(',')
    emails.map { |email| email.strip }
    SharingMailer.share_image_email(params[:id], emails, current_user.id, params[:email]['message']).deliver
    redirect_to :action => 'browse', :id => params[:id]
  end

  def index
    if find_gallery!
      @images = @gallery.images.load_images(@filtered_params)

      if request.xhr?
        @images = @images.map { |image|
          { :name => image.name,
            :description => image.description,
            :size => image.data_file_size,
            :url => image.data.url,
            :thumbnail_url => image.data(:thumb),
            :delete_url => "/galleries/#{@gallery.id}/images/delete/#{image.id}",
            :edit_url => url_for(:controller => 'images', :action => 'show', :id => image.id),
            :image_id => image.id
          }
        }
        return render :json => @images
      else
        render :template => 'images/index_new', :layout => 'main'
      end
    end
  end

  def new
  end

  def destroy
    if request.xhr?
      image = Image.find_by_id params[:id]
      gallery = image.gallery
      images = gallery.images.load_images(@filtered_params)

      image.destroy
      pagination = render_to_string :partial => 'shared/pagination',
        :locals => {  :source => images, :params => { :controller => 'galleries',
          :action => 'edit_images', :gallery_id => gallery.id }, :classes => 'text left' }
      items = render_to_string :partial => 'galleries/edit_photos',
                              :locals => { :images => images }
      gal_options = self.class.helpers.gallery_options(current_user.id, gallery.id, true)
      render :json => { :items => items, :pagination => pagination, :gallery_options => gal_options }
    else
      ids = params[:id]
      ids = params[:id].join(',') if params[:id].instance_of? Array
      Image.destroy_all("id in (#{ids})")
      render :json => {:success => true}
    end
  end

  def public_images
    if find_gallery!
      @images = @gallery.images.load_popular_images(@filtered_params)
    end
  end

  def get_image_data
    img = Image.find_by_id params[:id]
    img_url = img.url(params[:size])
    img_data = Magick::Image.read(img_url).first
    send_data(img_data.to_blob, :disposition => 'inline', :type => 'image/jpeg')
  end

  def create
    data = params[:image][:data]
    img_size = File.new(data[0].tempfile).size
    if img_size > current_user.free_allocation
      mb_unit = FileSizeConverter::UNITS[:megabyte]
      mb_img_size = FileSizeConverter.convert img_size, FileSizeConverter::UNITS[:byte], mb_unit
      free_allocation = [0, (FileSizeConverter.convert current_user.free_allocation, FileSizeConverter::UNITS[:byte], mb_unit)].max
      result = [{:error => "UPLOAD FAILED! This image is #{mb_img_size} #{mb_unit.upcase}. You have only #{free_allocation} #{mb_unit.upcase} / #{User::ALLOCATION_STRING} free" }]
      # raise exception
      render :text => result.to_json and return
    end

    image_info = {
      :name => data[0].original_filename,
      :gallery_id => params[:gallery_id],
      :data => data[0]
    }
    image = Image.new image_info
    image.price = rand(50) #tmp for randomzise price
    unless image.save
      result = [{:error => 'Cannot save image' }]
    else
      gallery = Gallery.find_by_id params[:gallery_id]
      images = gallery.images.load_images(@filtered_params)
      pagination = render_to_string :partial => 'shared/pagination',
        :locals => {  :source => images, :params => { :controller => 'galleries',
          :action => 'edit_images', :gallery_id => gallery.id }, :classes => 'text left' }
      item = render_to_string :partial => 'images/edit_photo_template',
                              :locals => { :image => image }
      gal_options = self.class.helpers.gallery_options(current_user.id, gallery.id, true)
      result = {
        :item => item, :pagination => pagination, :gallery_options => gal_options
      }
    end

    render :json => result
  end

  def list
    if find_gallery!
      @images = @gallery.images.load_images(@filtered_params)
      @page_id = @filtered_params[:page_id].nil? ? 1 : @filtered_params[:page_id]
      @page_size = @filtered_params[:page_size]
    end
  end

  def switch_liked
    result = {:success => false}
    image = Image.find_by_id(params[:id])
    if image.nil?
      result[:msg] = "This image does not exist anymore!"
      return render :json => result
    end
    if user_signed_in?
      result = SharedMethods::Converter.Boolean(params[:dislike]) ? image.disliked_by_user(current_user.id) : image.liked_by_user(current_user.id)
    else
      result[:msg] = "You have to sign in first"
    end
    render :json => result
  end

  # GET images/:id/slideshow
  # params: id => Image ID
  def show
    redirect_list = [ url_for(:controller=>"images", :action=>"list", :only_path => false),
                      url_for(:controller=>"images", :action=>"index", :only_path => false)]
    push_redirect if redirect_list.index(request.env["HTTP_REFERER"])
    # get selected Image
    @selected_image = Image.find_by_id(params[:id])
    if (@selected_image.nil?)
      return render_not_found
    end
    # get Gallery
    @images = @selected_image.gallery.images.all(:order => 'id')
    # get Images belongs Gallery
  end

  def get_flickr_authorize
    FlickRaw.api_key = FLICKER_API_KEY
    FlickRaw.shared_secret = FLICKER_SHARED_SECRET
    flickr = FlickRaw::Flickr.new
    token = flickr.get_request_token(:oauth_callback => url_for(:controller => 'images', :action => 'flickr_response', :image_id => params[:image_id], :only_path => false))

    session[:flickr_token_secret] = token['oauth_token_secret']
    auth_url = flickr.get_authorize_url(token['oauth_token'], :perms => 'write')
    redirect_to auth_url
  end

  # response: { "oauth_token"=>"72157629828499297-421d9d93795a9b2b",
  #             "oauth_verifier"=>"c1ae746b4a78bb78",
  #             "controller"=>"images", "action"=>"flickr_response"}
  def flickr_response
    verify = params['oauth_verifier'].strip
    flickr.get_access_token(params['oauth_token'], session[:flickr_token_secret], verify)
    session.delete :flickr_token_secret
    session[:flickr_verify_key] = verify
    uplo_photoset = push_to_uplo_photoset(params[:image_id])

    return redirect_to :action => :browse, :id => params[:image_id]#, :flickr_post => 'success'
  end

  def post_image_to_flickr
    redirect_to :action => :get_flickr_authorize, :image_id => params[:id]
    # if session.has_key?(:flickr_verify_key)==false || session[:flickr_verify_key].nil? || session[:flickr_verify_key]==''
    #   return redirect_to :action => :get_flickr_authorize, :image_id => params[:id]
    # end

    # push_to_uplo_photoset params[:id]
    # return redirect_to :action => :browse, :id => params[:id], :flickr_post => 'success'
  end

  # GET images/:id/browse
  def browse
    push_redirect
    @image = Image.find_by_id(params[:id])
    if @image.blank?
      return render_not_found
    elsif @image.gallery && !@image.gallery.can_access?(current_user)
      return render_unauthorized
    end

    # if params.has_key?(:flickr_post) && params[:flickr_post]=='success'
    #   @flickr_post = true
    # elsif params.has_key?(:flickr_post) && params[:flickr_post]!='success'
    #   @flickr_post = false
    # end

    # @images = @image.gallery.images.all(:order => 'name')
    @images = @image.gallery.get_images_without([@image.id])
    @author = @image.gallery.user
    @dislike = false
    if user_signed_in?
      @dislike = @image.is_liked? current_user.id
    end

    @purchased_info = @image.raw_purchased_info(@filtered_params)
    render :template => "images/browse_new", :layout => "main"
  end

  def public
    # if user_signed_in?
    #   return redirect_to :action => 'browse', :id => params[:id]
    # end
    @image = Image.find_by_id(params[:id])
    @author = @image.gallery.user
    @purchased_info = @image.raw_purchased_info(@filtered_params)
    render :layout => 'public', :formats => 'html'
  end

  # PUT images/:id/slideshow_update
  # params: id => Image ID
  def update
    image = Image.find_by_id params[:id]
    img_info = params[:image]
    # if request.xhr?
    #   worker = FilterWorker.new
    #   worker.image_id = image.id
    #   worker.image_url = image.data.url
    #   worker.effect = img_info[:filtered_effect]
    #   worker.queue #put task to iron worker

    #   return render :json => {:task_id => worker.task_id}
    # end

    img_info.delete :filtered_effect
    image.attributes = img_info
    image.save
    redirect_to :action => :browse
  end

  def update_images
    data = JSON.parse params[:images]
    data.each do |img|
      id = img.delete 'id'
      image = Image.find_by_id id.to_i
      if image.nil?
      else
        is_cover = img.delete 'is_album_cover'
        is_avatar = img.delete 'is_avatar'
        image.set_as_album_cover if SharedMethods::Converter::Boolean(is_cover)
        image.set_as_owner_avatar if SharedMethods::Converter::Boolean(is_avatar)
        image.update_attributes img
      end
    end

    gallery = Gallery.find_by_id params[:gallery_id].to_i
    images = gallery.images.load_images(@filtered_params)
    pagination = render_to_string :partial => 'shared/pagination',
      :locals => {  :source => images, :params => { :controller => 'galleries',
        :action => 'edit_images', :gallery_id => gallery.id }, :classes => 'text left' }
    items = render_to_string :partial => 'galleries/edit_photos',
                            :locals => { :images => images }
    result = {
      :items => items, :pagination => pagination
    }

    render :json => result
  end

  def get_filter_status
    task = IronWorker.service.status params[:task_id]
    success = (task["status"]=="cancelled" || task["status"]=="error")
    if task["status"]=="complete"
      image = Image.find_by_id params[:id]
      img_info = params[:image].delete :filtered_effect
      image.attributes = img_info
      file_path = "#{ Rails.root }/tmp/#{ image.name }_#{ Time.now.strftime('%Y%m%d%H%M%S%9N') }.jpg"
      img = Magick::Image.read(image.data.url).first
      img.write file_path
      image.data = File.open file_path
      success = image.save
    end

    render :json => {
      :status => task["status"],
      :success => success
    }
  end

  def order
    @image = Image.find_by_id(params[:id])
    if params[:line_item].nil?
      if @image.blank?
        return render_not_found
      elsif @image.gallery && !@image.gallery.can_access?(current_user)
        return render_unauthorized
      end
    else
      @line_item = LineItem.find_by_id params[:line_item]
    end
    render :template => "images/order_new", :layout => "main"
  end

  protected

  def set_current_tab
    tab = "galleries"
    browse_actions = ["browse", "order", "public_images"]
    unless browse_actions.index(params[:action]).nil?
      tab = "browse"
    end

    @current_tab = tab
  end

  def default_page_size
    actions = ['index']
    if params[:action] == 'create'
      size = 10
    elsif actions.index(params[:action]) == nil
      size = 12
    else
      size = 24
    end
    return size
  end

  def find_gallery
    @gallery = Gallery.find_by_id(params[:gallery_id])
  end

  def find_gallery!
    self.find_gallery
    if @gallery.blank?
      render_not_found
      return false
    elsif !@gallery.can_access?(current_user) ||
          (!@gallery.is_owner?(current_user) && %w(edit update destroy create list).include?(params[:action]))
      render_unauthorized
      return false
    end
    @gallery
  end

  def push_to_uplo_photoset(image_id)
    image = Image.find_by_id image_id
    image_data = Magick::Image.read(image.data.url(:medium)).first
    image_tmp_path = "#{Rails.root}/tmp/#{image.name}"
    image_data.write image_tmp_path
    photo_id = flickr.upload_photo image_tmp_path, :title => image.name, :description => "#{image.description} \ndetail at <a href='#{url_for(:controller => 'images', :action => 'browse', :id => image_id)}'>UPLO"
    photosets = flickr.photosets.getList
    photosets.each do |photoset|
      if photoset['title'] == 'UPLO'
        flickr.photosets.addPhoto :photoset_id => photoset['id'], :photo_id => photo_id
        flickr.photosets.setPrimaryPhoto :photoset_id => photoset['id'], :photo_id => photo_id
        return true
      end
    end
    flickr.photosets.create(:title => 'UPLO', :description => "from <a href='#{DOMAIN}'>UPLO</a>", :primary_photo_id => photo_id)
    return true
  end

  def detect_device
    if is_mobile_device? && params[:action]=='public' && (params[:web_default].nil? || params[:web_default]==false)
      @type = 'image'
      @id = params[:id]
      return render :template => 'shared/device_request', :layout => nil
    else
      request.formats.unshift Mime::HTML
    end
  end
end
