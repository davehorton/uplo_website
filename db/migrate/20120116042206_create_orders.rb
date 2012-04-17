class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :user_id
      t.float :tax
      t.float :price_total
      t.float :order_total
      t.string :transaction_code
      t.string :transaction_status
      t.datetime :transaction_date
      t.string :status
      t.string :receiver_name
      t.string :address
      t.string :message
      t.integer :shipping_address_id
      t.integer :billing_address_id
      t.timestamps
    end
  end
end
