class AddTumblrSecretTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :tumblr_secret_token, :string
  end
end
