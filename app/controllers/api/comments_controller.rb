class Api::CommentsController < Api::BaseController
  # GET /api/images/:image_id/comments
  # optional:
  #   page
  #   per_page
  #   sort_field
  #   sort_direction
  def index
    image = Image.unflagged.find(params[:image_id])
    comments = image.comments.paginate_and_sort(filtered_params)
    render json: comments, meta: { total: comments.total_entries }
  end

  # POST /api/images/:image_id/comments
  # required:
  #  comment
  def create
    image = Image.unflagged.find(params[:image_id])

    comment = Comment.new(params[:comment])
    comment.user = current_user

    if gal.comment
      render json: comment, status: :created
    else
      render json: { msg: comment.errors.full_messages.to_sentence }, status: :bad_request
    end
  end
end