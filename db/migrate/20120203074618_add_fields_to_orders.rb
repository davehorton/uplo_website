class AddFieldsToOrders < ActiveRecord::Migration
  def change
    rename_column :orders, :receiver_name, :first_name
    add_column :orders, :last_name, :string
    add_column :orders, :city, :string
    add_column :orders, :country, :string
    add_column :orders, :country_code, :string
    add_column :orders, :state, :string
    add_column :orders, :payer_email, :string
    add_column :orders, :payment_type, :string
    add_column :orders, :payment_fee, :decimal, :precision => 8, :scale => 2
    add_column :orders, :currency, :string
    add_column :orders, :transaction_subject, :string
    add_column :orders, :zip_code, :string
    add_column :orders, :card_type, :string
    add_column :orders, :card_number, :string
    add_column :orders, :expiration, :string
    add_column :orders, :cvv, :string
    
    # Change money column to decimal
    change_column :orders, :price_total, :decimal, :precision => 16, :scale => 2
    change_column :orders, :order_total, :decimal, :precision => 16, :scale => 2
    change_column :line_items, :price, :decimal, :precision => 16, :scale => 2
  end
end
