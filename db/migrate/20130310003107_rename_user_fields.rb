class RenameUserFields < ActiveRecord::Migration
  def up
    rename_column :users, :is_admin, :admin
    rename_column :users, :is_removed, :removed
    rename_column :users, :is_banned, :banned
    rename_column :users, :is_enable_facebook, :facebook_enabled
    rename_column :users, :is_enable_twitter,  :twitter_enabled

    add_index :users, :removed
    add_index :users, :banned
  end

  def down
  end
end
