class AddMerchantCustomerIdToUsers < ActiveRecord::Migration
  def up
    add_column :users, :merchant_customer_id, :string, :limit => 20

    User.reset_column_information

    User.find_in_batches do |group|
      group.each do |user|
        user.set_merchant_customer_id
        user.save
      end
    end

  end

  def down
    remove_column :users, :merchant_customer_id
  end
end
