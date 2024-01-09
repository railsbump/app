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

ActiveRecord::Schema[7.1].define(version: 2020_02_01_222813) do
  create_table "compats", force: :cascade do |t|
    t.integer "rails_release_id"
    t.text "status_determined_by"
    t.integer "status"
    t.text "dependencies_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "checked_at"
    t.json "dependencies"
  end

  create_table "gemmies", force: :cascade do |t|
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "compat_ids", default: [], null: false
    t.json "dependencies_and_versions", default: {}
    t.check_constraint "JSON_TYPE(compat_ids) = 'array'", name: "gemmy_compat_ids_is_array"
  end

  create_table "github_notifications", force: :cascade do |t|
    t.string "conclusion"
    t.string "action", null: false
    t.string "branch", null: false
    t.json "data"
    t.datetime "processed_at"
    t.integer "compat_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["compat_id"], name: "index_github_notifications_on_compat_id"
  end

  create_table "lockfile_dependencies", id: false, force: :cascade do |t|
    t.integer "lockfile_id"
    t.integer "gemmy_id"
  end

  create_table "lockfiles", force: :cascade do |t|
    t.text "content"
    t.text "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rails_releases", force: :cascade do |t|
    t.text "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
