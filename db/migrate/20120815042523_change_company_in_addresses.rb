class ChangeCompanyInAddresses < ActiveRecord::Migration
  def change
    rename_column :addresses, :company, :optional_address
  end
end
