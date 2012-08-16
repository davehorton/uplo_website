class AddNameOnCardToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :name_on_card, :string
  end
end
