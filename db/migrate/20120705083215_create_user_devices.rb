class CreateUserDevices < ActiveRecord::Migration
  def change
    create_table :user_devices do |t|
      t.string :device_token, :null => false
      t.integer :user_id, :null => false
      t.boolean :notify_comments, :null => false, :default => true
      t.boolean :notify_likes, :null => false, :default => true
      t.boolean :notify_purchases, :null => false, :default => true
      t.datetime :last_notified, :null => false
      t.timestamps
    end
  end
end
