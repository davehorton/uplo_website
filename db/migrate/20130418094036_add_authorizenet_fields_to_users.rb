class AddAuthorizenetFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :an_customer_profile_id, :integer
    add_column :users, :an_customer_payment_profile_id, :integer
  end
end
