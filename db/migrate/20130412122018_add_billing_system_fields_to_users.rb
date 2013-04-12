class AddBillingSystemFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :billing_system_profile_id, :integer
    add_column :users, :customer_payment_profile_id, :integer
  end
end
