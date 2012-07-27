class AddIsRemovedIsBannedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_removed, :boolean, :default => false
    add_column :users, :is_banned, :boolean, :default => false
  end
end
