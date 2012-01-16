class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.string :name, :null => false
      t.text :description
      t.integer :gallery_id, :null => false
      t.boolean :is_gallery_cover, :default => false
      t.float :price
      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end
