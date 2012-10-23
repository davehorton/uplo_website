class AddFlickrSecretTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :flickr_secret_token, :string
  end
end
