class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.string :name, :null => false
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end
