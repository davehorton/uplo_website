class AddDataProessingToImages < ActiveRecord::Migration
  def change
  	add_column :images, :data_processing, :boolean
  end
end
