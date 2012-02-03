class AddFieldsToOrders < ActiveRecord::Migration
  def change
    rename_column :orders, :receiver_name, :first_name
    add_column :orders, :last_name, :string
    add_column :orders, :city, :string
    add_column :orders, :zip_code, :string
    add_column :orders, :card_type, :string
    add_column :orders, :card_number, :string
    add_column :orders, :expiration, :string
    add_column :orders, :cvv, :string
  end
end
