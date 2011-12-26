class CreateImageLikes < ActiveRecord::Migration
  def self.up
    create_table :image_likes do |t|
      t.integer :image_id, :null => false
      t.integer :user_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :image_likes
  end
end
