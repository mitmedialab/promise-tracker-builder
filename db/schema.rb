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

ActiveRecord::Schema.define(version: 20140815043203) do

  create_table "campaigns", force: true do |t|
    t.string   "title"
    t.text     "goal"
    t.integer  "submissions_target"
    t.text     "audience"
    t.text     "data_collectors"
    t.string   "status",             default: "draft"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "theme"
  end

  add_index "campaigns", ["user_id"], name: "index_campaigns_on_user_id", using: :btree

  create_table "inputs", force: true do |t|
    t.text     "label"
    t.text     "input_type"
    t.boolean  "required"
    t.integer  "order"
    t.text     "options"
    t.integer  "survey_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "guid"
    t.string   "media_type"
    t.boolean  "annotate"
  end

  create_table "surveys", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "guid"
    t.boolean  "template"
    t.integer  "campaign_id"
  end

  add_index "surveys", ["campaign_id"], name: "index_surveys_on_campaign_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "bio"
    t.string   "username"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
