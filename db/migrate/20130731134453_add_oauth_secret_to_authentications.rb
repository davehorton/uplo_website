class AddOauthSecretToAuthentications < ActiveRecord::Migration
  def change
    add_column :authentications, :oauth_secret, :string
  end
end
