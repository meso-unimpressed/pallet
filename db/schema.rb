# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100308104230) do

  create_table "pallet_auto_associated_roles", :force => true do |t|
    t.string "role_id"
  end

  create_table "pallet_global_configs", :force => true do |t|
    t.string   "root_path"
    t.string   "domain"
    t.string   "email_robot_address"
    t.integer  "max_upload_file_size", :default => 100
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "theme",                :default => "default"
  end

  create_table "pallet_one_click_accesses", :force => true do |t|
    t.integer  "pallet_id"
    t.string   "sub_path"
    t.string   "token"
    t.text     "email_receivers"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.string   "language"
    t.string   "email_notes"
    t.integer  "user_id"
    t.string   "download"
  end

  create_table "pallets", :force => true do |t|
    t.string   "name"
    t.string   "directory"
    t.string   "description"
    t.string   "file_types",                           :default => "*"
    t.boolean  "one_click_access_generation_by_users"
    t.boolean  "is_readonly"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "pallets_roles", :id => false, :force => true do |t|
    t.integer "pallet_id"
    t.integer "role_id"
  end

  create_table "roles", :force => true do |t|
    t.integer "parent_id"
    t.string  "title"
    t.string  "description"
  end

  create_table "roles_users", :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "session_logs", :force => true do |t|
    t.integer  "user_id"
    t.datetime "logged_in_at"
    t.datetime "logged_out_at"
    t.integer  "pallet_id"
    t.string   "oca_token"
    t.integer  "oca_creator_user_id"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                                 :null => false
    t.string   "email",              :default => ""
    t.string   "crypted_password",                      :null => false
    t.string   "password_salt",                         :null => false
    t.string   "persistence_token",                     :null => false
    t.boolean  "ldap_auth",          :default => false
    t.string   "name",               :default => ""
    t.integer  "login_count",        :default => 0,     :null => false
    t.integer  "failed_login_count", :default => 0,     :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "language"
  end

  add_index "users", ["last_request_at"], :name => "index_users_on_last_request_at"
  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token"

end
