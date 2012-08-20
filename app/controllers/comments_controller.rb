class CommentsController < ApplicationController
  before_filter :authenticate_user!
  def index
    image = Image.un_flagged.find_by_id params[:image_id]
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
    image = Image.un_flagged.find_by_id comment[:image_id]

    if image.nil?
      result = { :success => false, :msg => "This image does not exist anymore!" }
    elsif comment[:description].strip.blank?
      result = { :success => false, :msg => "Comment cannot be blank!" }
    else
      comment = Comment.new({:image_id => image.id, :user_id => current_user.id,
        :description => comment[:description].strip})
      if comment.save
        if current_user.id != image.author.id
          Notification.deliver_image_notification(image.id, current_user.id, Notification::TYPE[:comment])
        end
        data = image.comments.load_comments(@filtered_params)
        comments = render_to_string :partial => 'images/comments_template', :locals => { :comments => data }
        result = { :success => true, :comments => comments, :comments_number => data.total_entries }
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
