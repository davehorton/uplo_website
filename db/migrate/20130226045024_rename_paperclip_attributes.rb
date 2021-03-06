class RenamePaperclipAttributes < ActiveRecord::Migration
  def up
    rename_column :images, :data_file_name, :image_file_name
    rename_column :images, :data_content_type, :image_content_type
    rename_column :images, :data_file_size, :image_file_size
    rename_column :images, :data_updated_at, :image_updated_at

    rename_column :profile_images, :data_file_name, :avatar_file_name
    rename_column :profile_images, :data_content_type, :avatar_content_type
    rename_column :profile_images, :data_file_size, :avatar_file_size
    rename_column :profile_images, :data_updated_at, :avatar_updated_at
  end

  def down
  end
end
