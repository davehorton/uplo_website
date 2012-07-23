class AddPageviewToImages < ActiveRecord::Migration
  def change
    add_column :images, :pageview, :integer, :default => 0
  end
end
