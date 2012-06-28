class CreateProfileImages < ActiveRecord::Migration
  def up
    create_table :profile_images do |t|
      t.integer :user_id, :null => false
      t.boolean :default, :default => false, :null => false
      t.integer :link_to_image, :default => 0
      t.datetime :last_used, :null => false
      t.string :data_file_name, :null => false
      t.string :data_content_type, :null => false
      t.integer :data_file_size, :null => false
      t.datetime :data_updated_at, :null => false

      t.timestamps
    end
  end

  def down
    drop_table :profile_images
  end
end
