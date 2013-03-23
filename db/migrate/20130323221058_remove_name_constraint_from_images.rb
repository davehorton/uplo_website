class RemoveNameConstraintFromImages < ActiveRecord::Migration
  def up
    change_column_null :images, :name, true
  end

  def down
  end
end
