class AddGalleryIndex < ActiveRecord::Migration
  def change
    add_index :galleries, :name
  end
end
