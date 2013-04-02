class AddCropDimensionToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :crop_dimension, :string
  end
end
