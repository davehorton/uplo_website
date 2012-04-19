class AddKeywordToGalleries < ActiveRecord::Migration
  def change
    add_column :galleries, :keyword, :string
  end
end
