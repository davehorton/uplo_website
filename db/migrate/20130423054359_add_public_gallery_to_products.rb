class AddPublicGalleryToProducts < ActiveRecord::Migration
  def change
    add_column :products, :public_gallery, :boolean, :default => true
    add_column :products, :private_gallery, :boolean, :default => false
  end
end
