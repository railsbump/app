# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_02_01_222813) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "compats", force: :cascade do |t|
    t.jsonb "dependencies"
    t.boolean "compatible"
    t.datetime "checked_at"
    t.bigint "rails_release_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "compatible_reason"
    t.index ["dependencies", "rails_release_id"], name: "index_compats_on_dependencies_and_rails_release_id", unique: true
    t.index ["rails_release_id"], name: "index_compats_on_rails_release_id"
  end

  create_table "gemmies", force: :cascade do |t|
    t.string "name"
    t.jsonb "dependencies_and_versions", default: {}
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_gemmies_on_name", unique: true
  end

  create_table "github_notifications", force: :cascade do |t|
    t.jsonb "data"
    t.datetime "processed_at"
    t.bigint "compat_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["compat_id"], name: "index_github_notifications_on_compat_id"
  end

  create_table "lockfile_dependencies", id: false, force: :cascade do |t|
    t.bigint "lockfile_id"
    t.bigint "gemmy_id"
    t.index ["gemmy_id"], name: "index_lockfile_dependencies_on_gemmy_id"
    t.index ["lockfile_id"], name: "index_lockfile_dependencies_on_lockfile_id"
  end

  create_table "lockfiles", force: :cascade do |t|
    t.text "content"
    t.string "slug"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["slug"], name: "index_lockfiles_on_slug", unique: true
  end

  create_table "rails_releases", force: :cascade do |t|
    t.string "version"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["version"], name: "index_rails_releases_on_version", unique: true
  end

end
