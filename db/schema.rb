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

ActiveRecord::Schema.define(:version => 20130128093702) do

  create_table "calling_numbers", :force => true do |t|
    t.integer  "creator_id"
    t.string   "number"
    t.integer  "customer_id"
    t.integer  "case",        :default => 1
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.text     "address"
    t.string   "phone"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "customers", :force => true do |t|
    t.integer  "creator_id"
    t.string   "name"
    t.string   "phone"
    t.string   "contact_person"
    t.string   "mobile"
    t.string   "email"
    t.string   "bbm_pin"
    t.text     "office_address"
    t.boolean  "is_corporate_customer", :default => false
    t.boolean  "is_deleted",            :default => false
    t.boolean  "is_delayed_payment",    :default => false
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  create_table "deliveries", :force => true do |t|
    t.string   "code"
    t.integer  "company_id"
    t.integer  "creator_id"
    t.integer  "customer_id"
    t.integer  "project_id"
    t.integer  "drop_center_id"
    t.integer  "case",                                               :default => 1
    t.integer  "delivery_scenario_id"
    t.integer  "price_id"
    t.decimal  "discount",             :precision => 5, :scale => 2, :default => 0.0
    t.text     "discount_note"
    t.decimal  "amount",               :precision => 9, :scale => 2, :default => 0.0
    t.integer  "employee_id"
    t.text     "pickup_address"
    t.text     "delivery_address"
    t.boolean  "is_picked_up",                                       :default => false
    t.datetime "pickup_time"
    t.boolean  "is_delivered",                                       :default => false
    t.datetime "delivery_time"
    t.boolean  "is_approved",                                        :default => false
    t.datetime "approval_time"
    t.integer  "approver_id"
    t.datetime "approved_at"
    t.integer  "canceler_id"
    t.datetime "cancel_datetime"
    t.boolean  "is_canceled",                                        :default => false
    t.integer  "cancel_case",                                        :default => 1
    t.decimal  "cancelation_fee",      :precision => 9, :scale => 2, :default => 0.0
    t.text     "cancel_note"
    t.boolean  "is_paid",                                            :default => false
    t.integer  "payment_approver_id"
    t.datetime "created_at",                                                            :null => false
    t.datetime "updated_at",                                                            :null => false
  end

  create_table "delivery_areas", :force => true do |t|
    t.integer  "creator_id"
    t.integer  "company_id"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "delivery_scenarios", :force => true do |t|
    t.integer  "company_id"
    t.integer  "creator_id"
    t.integer  "source_id"
    t.integer  "target_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "employees", :force => true do |t|
    t.integer  "creator_id"
    t.integer  "company_id"
    t.string   "name"
    t.string   "code"
    t.string   "mobile_phone"
    t.text     "address"
    t.boolean  "is_deleted",   :default => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "prices", :force => true do |t|
    t.integer  "creator_id"
    t.integer  "company_id"
    t.integer  "delivery_scenario_id"
    t.integer  "customer_id"
    t.decimal  "price",                :precision => 9, :scale => 2, :default => 0.0
    t.boolean  "is_active",                                          :default => true
    t.datetime "created_at",                                                           :null => false
    t.datetime "updated_at",                                                           :null => false
  end

  create_table "roles", :force => true do |t|
    t.string   "name",        :null => false
    t.string   "title",       :null => false
    t.text     "description", :null => false
    t.text     "the_role",    :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "role_id"
    t.string   "name"
    t.string   "username"
    t.string   "login"
    t.boolean  "is_deleted",             :default => false
    t.boolean  "is_main_user",           :default => false
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
