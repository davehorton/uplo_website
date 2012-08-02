class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.string :email, :null => false
      t.string :token, :null => false
      t.datetime :invited_at
      t.timestamps
    end
  end
end
