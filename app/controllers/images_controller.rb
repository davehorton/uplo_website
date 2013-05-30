class ImagesController < ApplicationController
  self.per_page = 30

  skip_before_filter :authenticate_user!, only: [:public, :browse, :index]
  skip_authorize_resource :only => :public

  def index
    find_gallery_and_authorize
    @images = @gallery.images.unflagged.paginate_and_sort(filtered_params)
  end

  def show
    @image  = Image.unflagged.find(params[:id])
    @images = @image.gallery.images.unflagged.all(order: 'images.id')
    render layout: 'application'
  end

  def create
    gallery = current_user.galleries.find(params[:gallery_id])
    image_params = params["files"].first
    image = Image.new(gallery_id: gallery.id, name: image_params.original_filename, image: image_params)
    image.user = current_user

    if image.save!
      images = gallery.images.unflagged.paginate_and_sort(filtered_params)

      pagination = render_to_string(
        partial: 'pagination',
        locals: {
          source: images,
          params: {
            controller: 'galleries',
            action:     'edit_images',
            gallery_id: gallery.id
          },
          classes: 'text left'
        })

      item = render_to_string(
        partial: 'images/edit_photo_template',
        locals: { image: image })

      gal_options = self.class.helpers.gallery_options(current_user.id, gallery.id, true)

      render json: { success: true, item: item, pagination: pagination, gallery_options: gal_options },
             content_type: 'text/plain'
    else
      render(json: { msg: image.errors.full_messages.join(', ') }, content_type: 'text/plain') and return
    end
  end

  def edit
    @image = current_user.images.unflagged.find(params[:id])
  end

  def update
    image = current_user.images.unflagged.find(params[:id])
    img_info = params[:image]
    img_info.delete :filtered_effect
    image.attributes = img_info
    image.save
    redirect_to browse_image_path(image)
  end

  def destroy
    if request.xhr?
      image = current_user.images.find_by_id params[:id]
      gallery = image.gallery
      if(!current_user.owns_image?(image))
        render :json => {:success => false, :msg => "You're not the owner of this image"} and return
      end
      images = gallery.images.unflagged.paginate_and_sort(filtered_params)

      if image.destroy
        pagination = render_to_string :partial => 'pagination',
          :locals => {  :source => images, :params => { :controller => 'galleries',
            :action => 'edit_images', :id => gallery.id }, :classes => 'text left' }
        items = render_to_string :partial => 'galleries/edit_photos',
                                :locals => { :images => images }
        gal_options = self.class.helpers.gallery_options(current_user.id, gallery.id, true)
        render :json => { :success => true, :items => items, :pagination => pagination, :gallery_options => gal_options }
      else
        render :json => {:msg => "Could not delete image"}
      end
    else
      ids = params[:id]
      ids = params[:id].join(',') if params[:id].instance_of? Array
      if current_user.images.where(id: ids).destroy
        render :json => {:success => true}
      else
        render :json => {:msg => "Could not delete images"}
      end
    end
  end

  def mail_shared_image
    begin
      emails = params[:email]['emails'].split(',')
      email_format = Regexp.new(/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/)
      emails.map do |email|
        if(email_format.match(email))
          email.strip
        else
          raise "The email #{email} is invalid"
        end
      end

      if emails.length > 0 && SharingMailer.delay.share_image_email(params[:id], emails, current_user.id, params[:email]['message'])
        flash[:notice] = "Email sent"
      else
        flash[:warning] = "Could not send the email. Please re-check your information (email, message)."
      end
    rescue Exception => e
      flash[:warning] = e.message
    ensure
      redirect_to browse_image_path(params[:id])
    end
  end

  def public
    @image = Image.not_removed.public_access.find_by_id(params[:id])
    if @image.nil?
      redirect_to root_path
    else
      redirect_to browse_image_path(@image)
    end
  end

  def public_images
    find_gallery_and_authorize
    @images = @gallery.images.popular_with_pagination(filtered_params, current_user)
    render :layout => 'application'
  end

  def get_image_data
    img = Image.find_by_id params[:id]
    img_url = img.url(params[:size])
    img_data = Magick::Image.read(img_url).first
    send_data(img_data.to_blob, :disposition => 'inline', :type => 'image/jpeg')
  end

  def switch_like
    image = Image.find_by_id(params[:id])
    return redirect_to browse_image_path(image) if request.get?

    dislike = params[:dislike].to_bool
    if image.nil? || (image.image_flags.count > 0 && !current_user.owns_image?(image))
      result = { :success => false, :msg => "This image does not exist anymore!" }
    elsif dislike
      result = current_user.unlike_image(image)
    else
      result = current_user.like_image(image)
    end

    render :json => result
  end

  def flickr_authorize
    FlickRaw.api_key = FLICKR_CONFIG["api_key"]
    FlickRaw.shared_secret = FLICKR_CONFIG["secret"]
    flickr = FlickRaw::Flickr.new
    token = flickr.get_request_token(oauth_callback: flickr_response_image_url(params[:id]))

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
    uplo_photoset = push_to_uplo_photoset(params[:id])
    redirect_to browse_image_path(params[:id])
  end

  def flickr_post
    redirect_to flickr_authorize_image_path(params[:id])
  end

  def browse
    push_redirect
    self.per_page = 10

    @image = Image.find_by_id(params[:id])

    if @image.nil?
      render_not_found
    elsif current_user && !current_user.can_access?(@image.gallery)
      render_unauthorized
    end

    @is_owner = current_user && current_user.owns_image?(@image)

    if @is_owner
      @images = @image.gallery.images.unflagged.where("images.id not in (#{@image.id})").order('name')
    else
      @images = @image.gallery.get_images_without([@image.id])
    end

    @author = @image.user
    @dislike = false
    if user_signed_in?
      @dislike = @image.liked_by?(current_user)
    end

    if @image.image_processing?
      flash[:processing_photo] = "Your uploaded photo is being processed. This may take a few moments."
      flash[:sticky_flash_message] = true
    end

    @comments = @image.comments.available.paginate_and_sort(filtered_params)

    # Increase page view
    @image.increase_pageview
  end

  def flag
    result = { success: false, msg: "" }
    image = Image.unflagged.find_by_id params[:id]
    if image.user.nil?
      result = { msg: "Member no longer exists" }
    elsif image.nil? && !current_user.admin?
      result = { msg: "Photo no longer exists" }
    else
      result = image.flag!(current_user, params)
    end
    render json: result
  end

  def update_images
    if !Gallery.exists?(id: params[:gallery_id], user_id: current_user.id)
      render(json: { msg: "You cannot edit another member's gallery!" }) and return
    end

    error = ''
    data = JSON.parse(params[:images])
    Image.transaction do
      data.each do |img|
        id = img.delete 'id'
        image = Image.unflagged.find_by_id id.to_i
        if image.nil? || (image.user.blocked? && !current_user.admin?)
          result = {
            :error => "Couldn't find photo"
          }

          render(:json => result) and return
        else
          next if image.image_processing
          if !(image.update_attributes img)
            error << image.errors.full_messages.to_sentence
          end
        end
      end
    end

    gallery = Gallery.find_by_id params[:gallery_id].to_i
    images = gallery.images.unflagged.paginate_and_sort(filtered_params)
    pagination = render_to_string :partial => 'pagination',
      :locals => {  :source => images, :params => { :controller => 'galleries',
        :action => 'edit_images', :gallery_id => gallery.id }, :classes => 'text left' }
    items = render_to_string :partial => 'galleries/edit_photos',
                            :locals => { :images => images }
    gal_options = self.class.helpers.gallery_options(current_user.id, gallery.id, true)
    result = {
      :items => items, :pagination => pagination, :gallery_options => gal_options, :error => error
    }

    render :json => result
  end

  def get_filter_status
    task = IronWorker.service.status params[:task_id]
    success = (task["status"]=="cancelled" || task["status"]=="error")
    if task["status"]=="complete"
      image = Image.unflagged.find_by_id params[:id]
      img_info = params[:image].delete :filtered_effect
      image.attributes = img_info
      file_path = "#{ Rails.root }/tmp/#{ image.name }_#{ Time.now.strftime('%Y%m%d%H%M%S%9N') }.jpg"
      img = Magick::Image.read(image.url ).first
      img.write file_path
      image.image = File.open file_path
      success = image.save
    end

    render :json => {
      :status => task["status"],
      :success => success
    }
  end

  def order
    @image = Image.find_by_id(params[:id])

    if @image.nil? || (@image.user.blocked? && !current_user.admin?)
      render_not_found
    end

    if params[:line_item].blank?
      if @image.blank?
        render_not_found
      elsif @image.gallery && !current_user.can_access?(@image.gallery)
        render_unauthorized
      end

      products = @image.available_products
      @product_options = products.first.product_options if products.any?
    else
      @line_item = LineItem.find_by_id(params[:line_item])
      @product_options = @line_item.product.product_options
    end

    @products = @image.available_products
  end

  def price
    @image = Image.find(params[:id])
    @product = Product.find(params[:product_id])

    viewing_own_image = (current_user && current_user.id == @image.user_id)

    render json: { success: true, price: @product.price_for_tier(@image.tier_id, viewing_own_image) }
  end

  def pricing
    image = Image.find(params[:id])
    if image.nil? || (image.user.blocked? && !current_user.admin?)
      result = { :success => false, :msg => 'This image does not exist anymore' }
    else
      table = render_to_string :partial => 'galleries/price_tiers', :locals => { :image => image }
      result = { :success => true, :price_table => table }
    end
    render :json => result
  end

  def product_options
    @image = Image.find(params[:id])
    @product = Product.find(params[:product_id])
    @product_options = @product.product_options
  end

  def print_image_preview
    @image = Image.find(params[:id])
    @product_option = ProductOption.find(params[:product_option_id])
    @preview_url = @image.find_or_generate_preview_image(@product_option)
  end

  def tier
    image = Image.find(params[:id])
    if image.nil? || (image.user.blocked? && !current_user.admin?)
      result = { :success => false, :msg => 'This image does not exist anymore' }
    else
      image.update_attributes(params[:image])
      result = { :success => true, :tier => image.tier_id }
    end
    render :json => result
  end

  protected

    def find_gallery_and_authorize
      @gallery = Gallery.find(params[:gallery_id])
      render_unauthorized if current_user && !current_user.can_access?(@gallery)
    end

    def push_to_uplo_photoset(image_id)
      image = Image.find_by_id image_id
      image_data = Magick::Image.read(image.url(:medium)).first
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
end
