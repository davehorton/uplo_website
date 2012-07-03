class CreateImageFlags < ActiveRecord::Migration
  def change
    create_table :image_flags do |t|
      t.integer :image_id, :null => false
      t.integer :reported_by, :null => false
      t.integer :flag_type, :null => false
      t.string :description
      t.timestamps
    end
  end
end
