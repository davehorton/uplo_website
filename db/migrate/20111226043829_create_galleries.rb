class CreateGalleries < ActiveRecord::Migration
  def self.up
    create_table :galleries do |t|
      t.integer :user_id, :null => false
      t.string :name, :null => false
      t.text :description
      t.string :permission
      t.boolean :delta, :default => true, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :galleries
  end
end
