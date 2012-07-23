# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120723044633) do

  create_table "addresses", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "company"
    t.string   "address"
    t.string   "city"
    t.string   "zip_code"
    t.string   "state"
    t.string   "phone_number"
    t.string   "fax_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "carts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.integer  "image_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "galleries", :force => true do |t|
    t.integer  "user_id",                       :null => false
    t.string   "name",                          :null => false
    t.text     "description"
    t.string   "permission"
    t.boolean  "delta",       :default => true, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "keyword"
  end

  create_table "image_flags", :force => true do |t|
    t.integer  "image_id",    :null => false
    t.integer  "reported_by", :null => false
    t.integer  "flag_type",   :null => false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "image_likes", :force => true do |t|
    t.integer  "image_id",   :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "image_tags", :force => true do |t|
    t.integer  "image_id",   :null => false
    t.integer  "tag_id",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", :force => true do |t|
    t.string   "name",                                 :null => false
    t.text     "description"
    t.integer  "gallery_id",                           :null => false
    t.boolean  "is_gallery_cover",  :default => false
    t.float    "price",             :default => 0.0
    t.boolean  "delta",             :default => true,  :null => false
    t.integer  "likes",             :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "data_file_name"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.datetime "data_updated_at"
    t.integer  "width"
    t.integer  "height"
    t.string   "keyword"
    t.boolean  "is_owner_avatar"
    t.integer  "pageview"
    t.boolean  "is_removed",        :default => false
    t.integer  "promote_num"
  end

  create_table "line_items", :force => true do |t|
    t.integer  "order_id"
    t.integer  "image_id"
    t.integer  "quantity",                                   :default => 0
    t.float    "tax",                                        :default => 0.0
    t.decimal  "price",       :precision => 16, :scale => 2, :default => 0.0
    t.boolean  "plexi_mount",                                :default => false
    t.string   "moulding"
    t.string   "size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", :force => true do |t|
    t.integer  "user_id"
    t.float    "tax"
    t.decimal  "price_total",         :precision => 16, :scale => 2
    t.decimal  "order_total",         :precision => 16, :scale => 2
    t.string   "transaction_code"
    t.string   "transaction_status"
    t.datetime "transaction_date"
    t.string   "status"
    t.string   "first_name"
    t.string   "address"
    t.string   "message"
    t.integer  "shipping_address_id"
    t.integer  "billing_address_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "last_name"
    t.string   "city"
    t.string   "country"
    t.string   "country_code"
    t.string   "state"
    t.string   "payer_email"
    t.string   "payment_type"
    t.decimal  "payment_fee",         :precision => 8,  :scale => 2
    t.string   "currency"
    t.string   "transaction_subject"
    t.string   "zip_code"
    t.string   "card_type"
    t.string   "card_number"
    t.string   "expiration"
    t.string   "cvv"
  end

  create_table "profile_images", :force => true do |t|
    t.integer  "user_id",                              :null => false
    t.boolean  "default",           :default => false, :null => false
    t.integer  "link_to_image",     :default => 0
    t.datetime "last_used",                            :null => false
    t.string   "data_file_name",                       :null => false
    t.string   "data_content_type",                    :null => false
    t.integer  "data_file_size",                       :null => false
    t.datetime "data_updated_at",                      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "user_devices", :force => true do |t|
    t.string   "device_token",                       :null => false
    t.integer  "user_id",                            :null => false
    t.boolean  "notify_comments",  :default => true
    t.boolean  "notify_likes",     :default => true
    t.boolean  "notify_purchases", :default => true
    t.datetime "last_notified",                      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_follows", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.integer  "followed_by", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "first_name",                                               :null => false
    t.string   "last_name",                                                :null => false
    t.string   "username"
    t.datetime "birthday"
    t.string   "nationality"
    t.string   "gender"
    t.string   "email",                                 :default => "",    :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "authentication_token"
    t.boolean  "delta",                                 :default => true,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "twitter"
    t.string   "facebook"
    t.string   "biography"
    t.string   "website"
    t.boolean  "is_admin",                              :default => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
