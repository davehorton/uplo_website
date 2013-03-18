class CommentSerializer < ActiveModel::Serializer
  attributes :duration, :commenter, :commenter_id, :commenter_avatar, :description

  def duration
    object.decorate.duration
  end
end
