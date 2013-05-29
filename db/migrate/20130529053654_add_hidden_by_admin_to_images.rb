class AddHiddenByAdminToImages < ActiveRecord::Migration
  def up
    add_column :images, :hidden_by_admin, :boolean, :default => false
  end

  def down
    remove_column :images, :hidden_by_admin
  end

end
