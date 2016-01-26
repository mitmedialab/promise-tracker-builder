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

ActiveRecord::Schema.define(version: 20150426140914) do

  create_table "api_keys", force: :cascade do |t|
    t.string   "access_token",     limit: 255
    t.string   "client_name",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "client_login_url", limit: 255
  end

  create_table "campaigns", force: :cascade do |t|
    t.string   "title",               limit: 255
    t.text     "goal",                limit: 65535
    t.integer  "submissions_target",  limit: 4
    t.text     "audience",            limit: 65535
    t.text     "data_collectors",     limit: 65535
    t.string   "status",              limit: 255,   default: "draft"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",             limit: 4
    t.string   "theme",               limit: 255
    t.text     "description",         limit: 65535
    t.text     "organizers",          limit: 65535
    t.boolean  "anonymous",           limit: 1
    t.string   "image_file_name",     limit: 255
    t.string   "image_content_type",  limit: 255
    t.integer  "image_file_size",     limit: 4
    t.datetime "image_updated_at"
    t.boolean  "campaign_page_valid", limit: 1
    t.text     "country",             limit: 65535
    t.text     "state",               limit: 65535
    t.text     "city",                limit: 65535
  end

  add_index "campaigns", ["user_id"], name: "index_campaigns_on_user_id", using: :btree

  create_table "campaigns_tags", id: false, force: :cascade do |t|
    t.integer "campaign_id", limit: 4, null: false
    t.integer "tag_id",      limit: 4, null: false
  end

  add_index "campaigns_tags", ["campaign_id"], name: "index_campaigns_tags_on_campaign_id", using: :btree
  add_index "campaigns_tags", ["tag_id"], name: "index_campaigns_tags_on_tag_id", using: :btree

  create_table "inputs", force: :cascade do |t|
    t.text     "label",      limit: 65535
    t.text     "input_type", limit: 65535
    t.boolean  "required",   limit: 1
    t.integer  "order",      limit: 4
    t.text     "options",    limit: 65535
    t.integer  "survey_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "surveys", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "template",    limit: 1
    t.integer  "campaign_id", limit: 4
    t.string   "title",       limit: 255
    t.integer  "code",        limit: 4
  end

  add_index "surveys", ["campaign_id"], name: "index_surveys_on_campaign_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string "label", limit: 255
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255,   default: "", null: false
    t.string   "encrypted_password",     limit: 255,   default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,     default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "bio",                    limit: 65535
    t.string   "username",               limit: 255
    t.string   "api_client_name",        limit: 255,   default: ""
    t.integer  "api_client_user_id",     limit: 4
    t.string   "avatar_file_name",       limit: 255
    t.string   "avatar_content_type",    limit: 255
    t.integer  "avatar_file_size",       limit: 4
    t.datetime "avatar_updated_at"
  end

  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
