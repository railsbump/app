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

ActiveRecord::Schema.define(version: 20151030111123) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "rubygems", force: :cascade do |t|
    t.string   "name",          limit: 255,                     null: false
    t.string   "status_rails4", limit: 255,                     null: false
    t.text     "notes_rails4"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status_rails5",             default: "unknown", null: false
    t.string   "notes_rails5"
  end

  add_index "rubygems", ["name"], name: "index_rubygems_on_name", unique: true, using: :btree

end
