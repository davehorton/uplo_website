class CreateUserFollows < ActiveRecord::Migration
  def change
    create_table :user_follows do |t|
      t.integer :user_id, :null => false
      t.integer :followed_by, :null => false

      t.timestamps
    end
  end
end
