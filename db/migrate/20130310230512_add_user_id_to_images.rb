class AddUserIdToImages < ActiveRecord::Migration
  def change
    add_column :images, :user_id, :integer
    add_index  :images, :user_id

    User.reset_column_information

    Image.find_each do |image|
      image.update_column(:user_id, image.gallery.user_id)
    end
  end
end
