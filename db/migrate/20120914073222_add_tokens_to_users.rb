class AddTokensToUsers < ActiveRecord::Migration
  def change
    add_column :users, :facebook_token, :string
    add_column :users, :twitter_token, :string
    add_column :users, :flickr_token, :string
    add_column :users, :tumblr_token, :string
    add_column :users, :pinterest_token, :string
  end
end
