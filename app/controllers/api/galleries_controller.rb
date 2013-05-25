class Api::GalleriesController < Api::BaseController
  # GET /api/galleries
  # params:
  #   page
  #   per_page
  #   sort_field
  #   sort_direction
  #   user_id (if null, list galleries of current user)
  def index
    if params[:user_id].blank?
      user = current_user
      galleries = user.galleries.scoped
    else
      user = User.find(params[:user_id])
      galleries = user.public_galleries.scoped
    end

    galleries = galleries.paginate_and_sort(filtered_params)
    render json: galleries, meta: { total: galleries.total_entries }
  end

  # POST /api/galleries
  def create
    gal = Gallery.new(filtered_params[:gallery])
    gal.user = current_user

    if gal.save
      render json: gal, status: :created
    else
      render json: { msg: gal.errors.full_messages.to_sentence }, status: :bad_request
    end
  end

  # PUT /api/galleries/:id
  def update
    gal = current_user_gallery

    if gal.update_attributes(filtered_params[:gallery])
      render json: gal
    else
      render json: { msg: gal.errors.full_messages.to_sentence }, status: :bad_request
    end
  end

  # DELETE /api/galleries/:id
  def destroy
    current_user_gallery.destroy
    render json: { msg: 'gallery deleted' }
  end
end
