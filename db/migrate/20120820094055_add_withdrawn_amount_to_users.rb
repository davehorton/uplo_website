class AddWithdrawnAmountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :withdrawn_amount, :float, :default => 0.0
  end
end
