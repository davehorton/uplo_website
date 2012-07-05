class CreateUserDevices < ActiveRecord::Migration
  def change
    create_table :user_devices do |t|
      t.string :device_token, :null => false
      t.integer :user_id, :null => false
      t.boolean :notify_comments, :default => true
      t.boolean :notify_likes, :default => true
      t.boolean :notify_purchases, :default => true
      t.datetime :last_notified, :null => false
      t.timestamps
    end
  end
end
