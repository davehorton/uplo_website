class RenameEmailFromGalleryInvitations < ActiveRecord::Migration
  def up
    rename_column :gallery_invitations, :email, :emails
    change_column :gallery_invitations, :emails, :text, :null => false
  end

  def down
  end
end
