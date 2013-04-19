class RemoveCreditCardFromOrders < ActiveRecord::Migration
  def up
    [:card_type, :card_number, :expiration, :cvv].each { |field| remove_column :orders, field}
  end

  def down
    [:card_type, :card_number, :expiration, :cvv].each { |field| add_column :orders, field, :string}
  end
end
