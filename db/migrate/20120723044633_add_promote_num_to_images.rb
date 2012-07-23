class AddPromoteNumToImages < ActiveRecord::Migration
  def change
    add_column :images, :promote_num, :integer
  end
end
