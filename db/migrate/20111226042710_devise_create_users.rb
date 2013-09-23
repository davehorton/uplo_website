class DeviseCreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :username
      t.datetime :birthday
      t.string :nationality
      t.string :gender

      ## Database authenticatable
      t.string :email,              null: false, default: ''
      t.string :encrypted_password, null: false, default: '', limit: 128

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at

      ## Token authenticatable
      t.string :authentication_token

      t.boolean :delta, default: true, null: false

      t.timestamps
    end

    add_index :users, :email,                unique: true
    add_index :users, :username,                unique: true
    add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true
    # add_index :users, :authentication_token, unique: true
  end

  def self.down
    drop_table :users
  end
end
