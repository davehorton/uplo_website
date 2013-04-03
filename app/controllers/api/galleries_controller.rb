class Api::GalleriesController < Api::BaseController

  respond_to :json

  skip_before_filter :require_login!, only: [:popular]

  # GET /api/galleries
  # params:
  #   page
  #   per_page
  #   sort_field
  #   sort_direction
  #   user_id: if null, list galleries of current user
  def index
    author = if filtered_params[:user_id]
      User.find(filtered_params[:user_id])
    else
      current_user
    end

    galleries = author.galleries.with_images.paginate_and_sort(filtered_params)
    render json: galleries, meta: { total: galleries.total_entries }
  end

  # GET /api/galleries/popular
  # params:
  #   page
  #   per_page
  #   sort_field
  #   sort_direction
  #   user_id
  def popular
    if params[:user_id].blank?
      galleries = Gallery.public_access.with_images.paginate_and_sort(filtered_params)
    else
      user = User.find(params[:user_id])

      if user == current_user
        galleries = user.with_images.paginate_and_sort(filtered_params)
      else
        galleries = user.public_galleries.with_images.paginate_and_sort(filtered_params)
      end
    end

    render json: galleries, meta: { total: galleries.total_entries }
  end

  # POST /api/galleries
  def create
    gal = GalleryDecorator.new(filtered_params[:gallery])
    gal.user = current_user

    if gal.save
      render json: gal, status: :created
    else
      render json: { msg: gal.errors.full_messages.to_sentence }, status: :bad_request
    end
  end

  # PUT /api/galleries/:id
  def update
    gal = current_user_gallery.update_attributes(filtered_params[:gallery])
    render json: gal, status: :ok
  end

  # DELETE /api/galleries/:id
  def destroy
    current_user_gallery.destroy
    head :ok
  end
end
