class AddPageviewToImages < ActiveRecord::Migration
  def change
    add_column :images, :pageview, :integer
  end
end
