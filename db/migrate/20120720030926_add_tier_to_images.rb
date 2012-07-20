class AddTierToImages < ActiveRecord::Migration
  def change
    add_column :images, :tier, :string
  end
end
