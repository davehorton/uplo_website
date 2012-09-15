class AddTwitterSecretTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :twitter_secret_token, :string
    add_column :users, :tumblr_secret_token, :string
  end
end
