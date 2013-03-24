class CreateMouldings < ActiveRecord::Migration
  def change
    create_table :mouldings do |t|
      t.string :name
      t.timestamps
    end
  end
end
