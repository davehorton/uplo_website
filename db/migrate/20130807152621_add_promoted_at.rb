class AddPromotedAt < ActiveRecord::Migration
  def up
    add_column :images, :promoted_at, :datetime
  end

  def down
    remove_column :images, :promoted_at
  end
end
