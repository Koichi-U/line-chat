# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_11_01_185923) do
  create_table "chats", force: :cascade do |t|
    t.string "message"
    t.integer "user_id"
    t.integer "lineuser_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lineuser_id"], name: "index_chats_on_lineuser_id"
    t.index ["user_id"], name: "index_chats_on_user_id"
  end

  create_table "follows", force: :cascade do |t|
    t.integer "lineuser_id"
    t.integer "active", default: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lineuser_id"], name: "index_follows_on_lineuser_id"
  end

  create_table "lineusers", force: :cascade do |t|
    t.string "displayname"
    t.string "userid"
    t.string "language"
    t.string "pictureurl"
    t.string "statusmessage"
    t.boolean "active", default: true, null: false
    t.string "lastmessage"
    t.datetime "lastmessagetime"
    t.boolean "read", default: false, null: false
    t.integer "readcount", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false, null: false
    t.boolean "active", default: false, null: false
    t.string "slackid"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.integer "invited_by_id"
    t.integer "invitations_count", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "chats", "lineusers"
  add_foreign_key "chats", "users"
  add_foreign_key "follows", "lineusers"
end
