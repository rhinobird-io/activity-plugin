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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150825093734) do

  create_table "attendances", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "speech_id"
    t.string   "role"
    t.integer  "point"
    t.integer  "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attendances", ["speech_id"], name: "index_attendances_on_speech_id"
  add_index "attendances", ["user_id"], name: "index_attendances_on_user_id"

  create_table "audiences", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "speech_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "audiences", ["speech_id"], name: "index_audiences_on_speech_id"
  add_index "audiences", ["user_id"], name: "index_audiences_on_user_id"

  create_table "exchanges", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "good_id"
    t.integer  "point"
    t.datetime "exchange_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "exchanges", ["exchange_time"], name: "index_exchanges_on_exchange_time"
  add_index "exchanges", ["good_id"], name: "index_exchanges_on_good_id"
  add_index "exchanges", ["user_id"], name: "index_exchanges_on_user_id"

  create_table "goods", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "picture"
    t.integer  "point"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "goods", ["point"], name: "index_goods_on_point"

  create_table "speeches", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "user_id"
    t.string   "slides"
    t.integer  "expected_duration"
    t.datetime "speech_time"
    t.integer  "status"
    t.integer  "category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "speeches", ["category"], name: "index_speeches_on_category"
  add_index "speeches", ["speech_time"], name: "index_speeches_on_speech_time"
  add_index "speeches", ["user_id"], name: "index_speeches_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "role"
    t.integer  "point"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["point"], name: "index_users_on_point"

end
