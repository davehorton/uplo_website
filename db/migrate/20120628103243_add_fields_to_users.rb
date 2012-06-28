class AddFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :biography, :string
    add_column :users, :website, :string
  end
end
