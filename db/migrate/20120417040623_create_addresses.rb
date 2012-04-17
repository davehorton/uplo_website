class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :first_name
      t.string :last_name
      t.string :company
      t.string :address
      t.string :city
      t.string :zip_code
      t.string :state
      t.string :phone_number
      t.string :fax_number

      t.timestamps
    end
  end
end
