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

ActiveRecord::Schema.define(:version => 20110709011655) do

  create_table "changeset_user_statuses", :force => true do |t|
    t.boolean  "accepted"
    t.integer  "user_id"
    t.integer  "changeset_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "changeset_user_statuses", ["user_id", "changeset_id"], :name => "index_changeset_user_statuses_on_user_id_and_changeset_id", :unique => true

  create_table "changesets", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "review_event_id"
    t.boolean  "submitted"
  end

  create_table "comments", :force => true do |t|
    t.text     "content"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "leftline"
    t.integer  "rightline"
  end

  add_index "comments", ["commentable_id", "commentable_type"], :name => "comment_index"
  add_index "comments", ["leftline", "rightline"], :name => "line_index"
  add_index "comments", ["leftline"], :name => "index_comments_on_leftline"
  add_index "comments", ["rightline"], :name => "index_comments_on_rightline"

  create_table "diffs", :force => true do |t|
    t.string   "origin_file"
    t.text     "contents"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "changeset_id"
    t.string   "updated_file"
  end

  create_table "profiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "display_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  create_table "review_event_users", :force => true do |t|
    t.integer  "review_event_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "review_event_users", ["id"], :name => "index_review_event_users_on_id"
  add_index "review_event_users", ["review_event_id", "user_id"], :name => "index_review_event_users_on_review_event_id_and_user_id", :unique => true

  create_table "review_events", :force => true do |t|
    t.string   "name"
    t.text     "notes"
    t.datetime "duedate"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
