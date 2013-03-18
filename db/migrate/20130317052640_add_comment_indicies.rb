class AddCommentIndicies < ActiveRecord::Migration
  def change
    add_index :comments, :image_id
    add_index :comments, :user_id
  end
end
