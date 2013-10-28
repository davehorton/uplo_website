class ChangeMessageFromInvitations < ActiveRecord::Migration
  def up
    change_column :invitations, :message, :text
  end

  def down
    change_column :invitations, :message, :string
  end
end
