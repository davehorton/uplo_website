class RemovePlexiMountFromLineItems < ActiveRecord::Migration
  def self.up
  end
  def self.down
    remove_column :line_items, :plexi_mount
  end
end
