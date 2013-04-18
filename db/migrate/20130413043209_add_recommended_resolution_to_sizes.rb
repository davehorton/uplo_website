class AddRecommendedResolutionToSizes < ActiveRecord::Migration
  def change
    add_column :sizes, :minimum_recommended_width, :integer
    add_column :sizes, :minimum_recommended_height, :integer
  end
end
