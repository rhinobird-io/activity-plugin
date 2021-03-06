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

ActiveRecord::Schema.define(version: 20160517081935) do

  create_table "attendances", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "speech_id"
    t.string   "role"
    t.integer  "point"
    t.boolean  "commented"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "liked",      default: false
  end

  add_index "attendances", ["speech_id"], name: "index_attendances_on_speech_id"
  add_index "attendances", ["user_id"], name: "index_attendances_on_user_id"

  create_table "audience_registrations", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "speech_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "audience_registrations", ["speech_id"], name: "index_audience_registrations_on_speech_id"
  add_index "audience_registrations", ["user_id"], name: "index_audience_registrations_on_user_id"

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "speech_id"
    t.string   "comment"
    t.string   "step"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["speech_id"], name: "index_comments_on_speech_id"

  create_table "exchanges", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "prize_id"
    t.integer  "point"
    t.datetime "exchange_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status"
  end

  add_index "exchanges", ["exchange_time"], name: "index_exchanges_on_exchange_time"
  add_index "exchanges", ["prize_id"], name: "index_exchanges_on_prize_id"
  add_index "exchanges", ["status"], name: "index_exchanges_on_status"
  add_index "exchanges", ["user_id"], name: "index_exchanges_on_user_id"

  create_table "prizes", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "picture_url"
    t.integer  "price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "exchanged_times"
    t.string   "status",          default: ""
  end

  add_index "prizes", ["exchanged_times"], name: "index_prizes_on_exchanged_times"
  add_index "prizes", ["price"], name: "index_prizes_on_price"
  add_index "prizes", ["status"], name: "index_prizes_on_status"

  create_table "speeches", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "user_id"
    t.string   "resource_url"
    t.integer  "expected_duration"
    t.datetime "time"
    t.string   "status"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_id"
    t.string   "resource_name"
    t.string   "video_resource_url",  default: ""
    t.string   "video_resource_name", default: ""
    t.string   "speaker_name"
  end

  add_index "speeches", ["category"], name: "index_speeches_on_category"
  add_index "speeches", ["time"], name: "index_speeches_on_time"
  add_index "speeches", ["user_id"], name: "index_speeches_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "role"
    t.integer  "point_available"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "point_total"
  end

  add_index "users", ["point_available"], name: "index_users_on_point_available"
  add_index "users", ["point_total"], name: "index_users_on_point_total"

end
