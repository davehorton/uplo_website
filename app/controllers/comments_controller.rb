class CommentsController < ApplicationController

  def index
    image = Image.find_by_id params[:image_id]
    if image.nil?
      result = { :success => false, :msg => "This image does not exist anymore!" }
    else
      data = image.comments.load_comments(@filtered_params)
      comments = render_to_string :partial => 'images/comments_template',
        :locals => { :comments => data }
      result = { :success => true, :comments => comments }
    end

    render :json => result
  end

  def create
    comment = params[:comment]
    image = Image.find_by_id comment[:image_id]

    if image.nil?
      result = { :success => false, :msg => "This image does not exist anymore!" }
    else
      comment = Comment.new({:image_id => image.id, :user_id => current_user.id,
        :description => comment[:description]})
      if comment.save
        if current_user.id != image.author.id
          Notification.deliver_image_notification(image.id, current_user.id, Notification::TYPE[:comment])
        end
        comments = render_to_string :partial => 'images/comments_template',
          :locals => { :comments => image.comments.load_comments(@filtered_params) }
        result = { :success => true, :comments => comments }
      else
        result = { :success => false, :msg => comment.errors.full_messages[0] }
      end
    end

    render :json => result
  end

  protected
    def default_page_size
      size = 10
      return size
    end
end