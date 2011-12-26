class CreateImageTags < ActiveRecord::Migration
  def self.up
    create_table :image_tags do |t|
      t.integer :image_id, :null => false
      t.integer :tag_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :image_tags
  end
end
