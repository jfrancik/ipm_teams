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

ActiveRecord::Schema.define(:version => 20120526001045) do

  create_table "contributions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "deliverable_id"
    t.integer  "score"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "deliverables", :force => true do |t|
    t.integer  "team_id"
    t.integer  "index"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.boolean  "submitted"
    t.integer  "mark"
  end

  create_table "history_items", :force => true do |t|
    t.integer  "team_id"
    t.integer  "user_id"
    t.integer  "deliverable_id"
    t.boolean  "submitted"
    t.text     "description"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "teams", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "k_number"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "password"
    t.integer  "privilege"
    t.string   "key"
    t.boolean  "ver"
    t.string   "salt"
    t.boolean  "passwd_reset"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "team_id"
    t.integer  "test_mark_A",  :default => -1
    t.integer  "test_mark_B",  :default => -1
    t.integer  "test_mark",    :default => -1
  end

end
