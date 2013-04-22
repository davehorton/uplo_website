class Api::ImagesController < Api::BaseController
  skip_before_filter :require_login!, only: [:index, :mouldings, :popular]

  respond_to :html, only: [:sale_chart]
  respond_to :json

  # GET /api/images
  # required:
  #   gallery_id or user_id
  # optional:
  #   page
  #   per_page
  #   sort_field
  #   sort_direction
  def index
    if gallery_id = filtered_params[:gallery_id]
      gallery = Gallery.find(gallery_id)
      images = gallery.images.unflagged
    else
      user = User.find(params[:user_id])

      if user == current_user
        images = current_user.images.unflagged
      else
        images = user.images.public_access
      end
    end

    images = images.with_gallery.paginate_and_sort(filtered_params)

    render json: images, meta: { total: images.size }
  end

  # GET /api/images/liked
  # optional:
  #   page
  #   per_page
  #   sort_field
  #   sort_direction
  def liked
    images = current_user.source_liked_images.paginate_and_sort(filtered_params)
    render json: images, meta: { total: images.size }
  end

  # GET /api/images/popular
  # optional:
  #   page
  #   per_page
  #   sort_field
  #   sort_direction
  def popular
    images = Image.spotlight.paginate_and_sort(filtered_params)
    render json: images, meta: { total: images.size }
  end

  # GET /api/images/search
  # required:
  #   query
  # optional:
  #   page
  #   per_page
  #   sort_field
  #   sort_direction
  def search
    raise 'Invalid request' if params[:query].blank?

    images = Image.search_scope(params[:query]).
              public_or_owner(current_user).
              paginate_and_sort(filtered_params)
    render json: images, meta: { total: images.size }
  end

  # GET /api/images/by_friends
  # optional:
  #   page
  #   per_page
  #   sort_field
  #   sort_direction
  def by_friends
    images = current_user.friends_images.popular_with_pagination(filtered_params)
    render json: images, meta: { total: images.size }
  end

  # GET /api/images/:id/ordering_options
  def ordering_options
    image = Image.unflagged.find(filtered_params[:id])
    render json: ImageSerializer.new(image).ordering_options
  end

  # GET /api/images/:id/mouldings
  def mouldings
    image = Image.unflagged.find(params[:id])
    render json: image.available_mouldings, root: 'mouldings'
  end

  # GET /api/images/:id/sizes
  def sizes
    image = Image.unflagged.find(params[:id])
    render json: image.available_sizes, root: 'sizes'
  end

  # POST /api/images
  # required:
  #   gallery_id
  #   image
  def create
    image = current_user_gallery.images.unflagged.build(filtered_params[:image])

    if image.save
      render json: image, status: :created
    else
      render json: { msg: image.errors.full_messages.to_sentence }, status: :bad_request
    end
  end

  # PUT /api/images/:id
  # required:
  #   image
  def update
    if current_user_image.update_attributes(filtered_params[:image])
      render json: image, status: :accepted
    else
      render json: { msg: image.errors.full_messages.to_sentence }, status: :bad_request
    end
  end

  # DELETE /api/images/:id
  def destroy
    current_user_image.destroy
    head :ok
  end

  # POST /api/images/:id/like
  def like
    image = Image.unflagged.find(params[:id])
    render json: current_user.like_image(image)
  end

  # PUT /api/images/:id/unlike
  def unlike
    image = Image.unflagged.find(params[:id])
    render json: current_user.unlike_image(image)
  end

  # GET /api/images/:id/total_sales
  def total_sales
    render json: {
      total: current_user_image.total_sales,
      sale_chart: url_for(:action => :sale_chart, :image_id => current_user_image.id, :only_path => false),
      sold_quantity: current_user_image.sold_quantity,
      purchased_info: current_user_image.get_purchased_info
    }
  end

  # GET /api/images/:id/purchases
  def purchases
    purchased_info = current_user_image.get_purchased_info

    render json: {
      total_sale: purchased_info[:total_sale],
      total_quantity: purchased_info[:total_quantity],
      data: purchased_info[:data]
    }
  end

  # GET /api/images/:id/sale_chart
  def sale_chart
    @monthly_sales = current_user_image.get_monthly_sales_over_year(Time.now, {:report_by => Image::SALE_REPORT_TYPE[:quantity]})
    render :file => "sale_chart.html.haml", :layout => false
  end

  # POST /api/images/:id/flag
  # required:
  #   type: see ImageFlag::FLAG_TYPE
  #   desc: description (not required for nudity flags)
  def flag_image
    image = Image.unflagged.find(params[:id])
    result = image.flag!(current_user, params)
    render json: result
  end
end
