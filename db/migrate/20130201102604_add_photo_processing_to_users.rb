class AddPhotoProcessingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :photo_processing, :boolean, :default => false
  end
end
