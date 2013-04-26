class CreateGalleryInvitations < ActiveRecord::Migration
  def change
    create_table :gallery_invitations do |t|
      t.integer :gallery_id, :null => false
      t.string :email, :null => false
      t.string :secret_token
      t.text :message
      t.integer :user_id
      t.timestamps
    end
    add_index :gallery_invitations, :secret_token
  end
end
