class ChangeColumnNameInAddresses < ActiveRecord::Migration
  def change
    rename_column :addresses, :address, :street_address
    rename_column :addresses, :zip_code, :zip
    rename_column :addresses, :phone_number, :phone
    rename_column :addresses, :fax_number, :fax
    change_column :addresses, :country, :string, :default => 'usa'
  end
end
