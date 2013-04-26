class CreateGalleryInvitations < ActiveRecord::Migration
  def change
    create_table :gallery_invitations do |t|
      t.integer :gallery_id, :null => false
      t.string :email, :null => false, :unique => true
      t.string :secret_token, :null => false
      t.boolean :accepted, :default => false
      t.string :message
      t.integer :user_id
      t.timestamps
    end
    add_foreign_key(:gallery_invitations, :galleries)
    add_index :gallery_invitations, :secret_token
  end
end
