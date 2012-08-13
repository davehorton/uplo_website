class AddInformationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :paypal_email, :string
    add_column :users, :location, :string
    add_column :users, :job, :string
    add_column :users, :name_on_card, :string
    add_column :users, :card_type, :string
    add_column :users, :card_number, :string
    add_column :users, :expiration, :string
    add_column :users, :cvv, :string
    add_column :users, :shipping_address_id, :integer
    add_column :users, :billing_address_id, :integer
    add_column :users, :is_enable_facebook, :boolean, :default => false
    add_column :users, :is_enable_twitter, :boolean, :default => false
    change_column :users, :biography, :text
  end
end
