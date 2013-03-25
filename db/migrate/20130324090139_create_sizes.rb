class CreateSizes < ActiveRecord::Migration
  def change
    create_table :sizes do |t|
      t.integer :width
      t.integer :height
      t.timestamps
    end
  end
end
