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

      t.timestamps
    end
  end
end
