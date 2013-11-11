class CreateUserNotifications < ActiveRecord::Migration
  def change
    create_table :user_notifications do |t|
      t.integer :user_id, :null => false
      t.boolean :push_like, :default => true
      t.boolean :push_comment, :default => true
      t.boolean :comment_email, :default => true
      t.boolean :push_purchase, :default => true
      t.boolean :push_follow, :default => true
      t.boolean :push_spotlight, :default => true
      t.timestamps
    end

    User.find_in_batches(batch_size: 100) do |group|
      group.each { |user| user.create_user_notification }
    end

  end
end
