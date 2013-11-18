class RepliesController < ApplicationController
  skip_before_filter :authenticate_user!

  def image_comment
    image_id = params[:to].gsub(/\D/, '')
    user = User.find_by_email(params[:from])
    parsed_body = EmailReplyParser.parse_reply(params[:text])
    user.comments.create!(description: parsed_body, image_id: image_id)
    redirect_to root_path
  end

end
