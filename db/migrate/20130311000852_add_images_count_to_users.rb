class AddImagesCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :images_count, :integer, default: 0
    add_index :users, :images_count
  end
end
