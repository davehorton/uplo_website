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

ActiveRecord::Schema.define(:version => 20130606130717) do

  create_table "addresses", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "optional_address"
    t.string   "street_address"
    t.string   "city"
    t.string   "zip"
    t.string   "state"
    t.string   "phone"
    t.string   "fax"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.string   "country",          :default => "usa"
  end

  create_table "carts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "order_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "carts", ["order_id"], :name => "index_carts_on_order_id"
  add_index "carts", ["user_id"], :name => "index_carts_on_user_id"

  create_table "comments", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.integer  "image_id"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "comments", ["image_id"], :name => "index_comments_on_image_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "galleries", :force => true do |t|
    t.integer  "user_id",                              :null => false
    t.string   "name",                                 :null => false
    t.text     "description"
    t.boolean  "delta",          :default => true,     :null => false
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "keyword"
    t.string   "permission",     :default => "public"
    t.boolean  "has_commission", :default => true,     :null => false
  end

  add_index "galleries", ["name"], :name => "index_galleries_on_name"
  add_index "galleries", ["permission"], :name => "index_galleries_on_permission"
  add_index "galleries", ["user_id"], :name => "index_galleries_on_user_id"

  create_table "gallery_invitations", :force => true do |t|
    t.integer  "gallery_id",   :null => false
    t.text     "emails",       :null => false
    t.string   "secret_token"
    t.text     "message"
    t.integer  "user_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "gallery_invitations", ["secret_token"], :name => "index_gallery_invitations_on_secret_token"

  create_table "image_flags", :force => true do |t|
    t.integer  "image_id",    :null => false
    t.integer  "reported_by", :null => false
    t.integer  "flag_type",   :null => false
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "image_flags", ["image_id"], :name => "index_image_flags_on_image_id"
  add_index "image_flags", ["reported_by"], :name => "index_image_flags_on_reported_by"

  create_table "image_likes", :force => true do |t|
    t.integer  "image_id",   :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "image_likes", ["image_id"], :name => "index_image_likes_on_image_id"
  add_index "image_likes", ["user_id"], :name => "index_image_likes_on_user_id"

  create_table "image_tags", :force => true do |t|
    t.integer  "image_id",   :null => false
    t.integer  "tag_id",     :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "image_tags", ["image_id"], :name => "index_image_tags_on_image_id"
  add_index "image_tags", ["tag_id"], :name => "index_image_tags_on_tag_id"

  create_table "images", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "gallery_id",                            :null => false
    t.boolean  "gallery_cover",      :default => false
    t.float    "price",              :default => 0.0
    t.boolean  "delta",              :default => true,  :null => false
    t.integer  "image_likes_count",  :default => 0
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "keyword"
    t.boolean  "owner_avatar",       :default => false
    t.boolean  "removed",            :default => false
    t.integer  "pageview",           :default => 0
    t.boolean  "image_processing",   :default => false
    t.integer  "user_id"
    t.boolean  "promoted",           :default => false
    t.integer  "tier_id"
    t.text     "image_meta"
    t.boolean  "hidden_by_admin",    :default => false
  end

  add_index "images", ["gallery_cover"], :name => "index_images_on_gallery_cover"
  add_index "images", ["gallery_id"], :name => "index_images_on_gallery_id"
  add_index "images", ["image_likes_count"], :name => "index_images_on_image_likes_count"
  add_index "images", ["image_processing"], :name => "index_images_on_data_processing"
  add_index "images", ["promoted"], :name => "index_images_on_promoted"
  add_index "images", ["removed"], :name => "index_images_on_removed"
  add_index "images", ["tier_id"], :name => "index_images_on_tier_id"
  add_index "images", ["user_id"], :name => "index_images_on_user_id"

  create_table "invitations", :force => true do |t|
    t.string   "email",      :null => false
    t.string   "token",      :null => false
    t.datetime "invited_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "message"
  end

  add_index "invitations", ["token"], :name => "index_invitations_on_token"

  create_table "line_items", :force => true do |t|
    t.integer  "order_id"
    t.integer  "image_id"
    t.integer  "quantity",                                            :default => 0
    t.float    "tax",                                                 :default => 0.0
    t.decimal  "price",                :precision => 16, :scale => 2, :default => 0.0
    t.boolean  "plexi_mount",                                         :default => false
    t.string   "moulding"
    t.string   "size"
    t.datetime "created_at",                                                             :null => false
    t.datetime "updated_at",                                                             :null => false
    t.float    "commission_percent"
    t.integer  "product_id"
    t.string   "crop_dimension"
    t.string   "content_file_name"
    t.string   "content_content_type"
    t.integer  "content_file_size"
    t.datetime "content_updated_at"
    t.integer  "product_option_id"
  end

  add_index "line_items", ["image_id"], :name => "index_line_items_on_image_id"
  add_index "line_items", ["order_id"], :name => "index_line_items_on_order_id"
  add_index "line_items", ["product_id"], :name => "index_line_items_on_product_id"

  create_table "mouldings", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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
    t.datetime "created_at",                                                          :null => false
    t.datetime "updated_at",                                                          :null => false
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
    t.float    "shipping_fee",                                       :default => 0.0
  end

  add_index "orders", ["user_id"], :name => "index_orders_on_user_id"

  create_table "product_options", :force => true do |t|
    t.integer  "product_id"
    t.string   "description"
    t.decimal  "border_top_bottom", :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "border_left_right", :precision => 8, :scale => 2, :default => 0.0
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
  end

  add_index "product_options", ["product_id"], :name => "index_product_options_on_product_id"

  create_table "products", :force => true do |t|
    t.integer  "size_id"
    t.integer  "moulding_id"
    t.decimal  "tier1_price",      :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "tier2_price",      :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "tier3_price",      :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "tier4_price",      :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "tier1_commission", :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "tier2_commission", :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "tier3_commission", :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "tier4_commission", :precision => 8, :scale => 2, :default => 0.0
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.boolean  "public_gallery",                                 :default => true
    t.boolean  "private_gallery",                                :default => false
    t.decimal  "shipping_price",   :precision => 8, :scale => 2, :default => 0.0
  end

  add_index "products", ["moulding_id"], :name => "index_products_on_moulding_id"
  add_index "products", ["size_id"], :name => "index_products_on_size_id"

  create_table "profile_images", :force => true do |t|
    t.integer  "user_id",                                :null => false
    t.boolean  "default",             :default => false, :null => false
    t.integer  "link_to_image",       :default => 0
    t.string   "avatar_file_name",                       :null => false
    t.string   "avatar_content_type",                    :null => false
    t.integer  "avatar_file_size",                       :null => false
    t.datetime "avatar_updated_at",                      :null => false
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.text     "avatar_meta"
  end

  add_index "profile_images", ["link_to_image"], :name => "index_profile_images_on_link_to_image"
  add_index "profile_images", ["user_id"], :name => "index_profile_images_on_user_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "shipping_prices", :force => true do |t|
    t.integer  "product_id"
    t.integer  "quantity"
    t.decimal  "amount",     :precision => 8, :scale => 2
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  add_index "shipping_prices", ["product_id"], :name => "index_shipping_prices_on_product_id"

  create_table "sizes", :force => true do |t|
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.integer  "minimum_width_in_pixels"
    t.integer  "minimum_height_in_pixels"
  end

  create_table "tags", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "user_devices", :force => true do |t|
    t.string   "device_token",                       :null => false
    t.integer  "user_id",                            :null => false
    t.boolean  "notify_comments",  :default => true
    t.boolean  "notify_likes",     :default => true
    t.boolean  "notify_purchases", :default => true
    t.datetime "last_notified",                      :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "user_devices", ["user_id"], :name => "index_user_devices_on_user_id"

  create_table "user_follows", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.integer  "followed_by", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "user_follows", ["followed_by"], :name => "index_user_follows_on_followed_by"
  add_index "user_follows", ["user_id"], :name => "index_user_follows_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "first_name",                                                       :null => false
    t.string   "last_name",                                                        :null => false
    t.string   "username"
    t.datetime "birthday"
    t.string   "nationality"
    t.string   "gender"
    t.string   "email",                                         :default => "",    :null => false
    t.string   "encrypted_password",             :limit => 128, :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                 :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "authentication_token"
    t.boolean  "delta",                                         :default => true,  :null => false
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
    t.string   "twitter"
    t.string   "facebook"
    t.text     "biography"
    t.string   "website"
    t.boolean  "admin",                                         :default => false
    t.boolean  "removed",                                       :default => false
    t.boolean  "banned",                                        :default => false
    t.string   "paypal_email"
    t.string   "location"
    t.string   "job"
    t.string   "name_on_card"
    t.string   "card_type"
    t.string   "card_number"
    t.string   "expiration"
    t.string   "cvv"
    t.integer  "shipping_address_id"
    t.integer  "billing_address_id"
    t.boolean  "facebook_enabled",                              :default => false
    t.boolean  "twitter_enabled",                               :default => false
    t.float    "withdrawn_amount",                              :default => 0.0
    t.string   "facebook_token"
    t.string   "twitter_token"
    t.string   "flickr_token"
    t.string   "tumblr_token"
    t.string   "pinterest_token"
    t.string   "twitter_secret_token"
    t.string   "tumblr_secret_token"
    t.string   "flickr_secret_token"
    t.boolean  "photo_processing",                              :default => false
    t.integer  "image_likes_count",                             :default => 0
    t.integer  "images_count",                                  :default => 0
    t.integer  "an_customer_profile_id"
    t.integer  "an_customer_payment_profile_id"
  end

  add_index "users", ["banned"], :name => "index_users_on_banned"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["image_likes_count"], :name => "index_users_on_image_likes_count"
  add_index "users", ["images_count"], :name => "index_users_on_images_count"
  add_index "users", ["removed"], :name => "index_users_on_removed"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
