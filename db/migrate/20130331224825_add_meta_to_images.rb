class AddMetaToImages < ActiveRecord::Migration
  def change
    add_column :images,         :image_meta,  :text
    add_column :profile_images, :avatar_meta, :text
  end
end
