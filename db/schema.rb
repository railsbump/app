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

ActiveRecord::Schema[8.0].define(version: 2026_04_21_204234) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "api_keys", force: :cascade do |t|
    t.string "name"
    t.string "key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_api_keys_on_key", unique: true
    t.index ["name"], name: "index_api_keys_on_name", unique: true
  end

  create_table "compats", force: :cascade do |t|
    t.bigint "rails_release_id"
    t.text "status_determined_by"
    t.bigint "status"
    t.text "dependencies_key"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
    t.timestamptz "checked_at"
    t.json "dependencies"
  end

  create_table "gem_checks", force: :cascade do |t|
    t.bigint "lockfile_check_id", null: false
    t.string "gem_name", null: false
    t.string "locked_version"
    t.string "source"
    t.string "status", default: "pending", null: false
    t.string "result"
    t.string "earliest_compatible_version"
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lockfile_check_id", "gem_name"], name: "index_gem_checks_on_lockfile_check_id_and_gem_name", unique: true
    t.index ["lockfile_check_id"], name: "index_gem_checks_on_lockfile_check_id"
  end

  create_table "gemmies", force: :cascade do |t|
    t.text "name"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
    t.json "compat_ids", default: []
    t.json "dependencies_and_versions", default: {}
  end

  create_table "github_notifications", force: :cascade do |t|
    t.text "conclusion"
    t.text "action"
    t.text "branch"
    t.json "data"
    t.timestamptz "processed_at"
    t.bigint "compat_id"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
    t.index ["compat_id"], name: "idx_24861_index_github_notifications_on_compat_id"
  end

  create_table "inaccessible_gemmies", force: :cascade do |t|
    t.text "name"
    t.bigint "lockfile_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lockfile_id", "name"], name: "index_inaccessible_gemmies_on_lockfile_id_and_name", unique: true
    t.index ["lockfile_id"], name: "index_inaccessible_gemmies_on_lockfile_id"
  end

  create_table "lockfile_checks", force: :cascade do |t|
    t.bigint "lockfile_id", null: false
    t.bigint "rails_release_id", null: false
    t.string "status", default: "pending", null: false
    t.string "ruby_version"
    t.string "rubygems_version"
    t.string "bundler_version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "current_rails_version"
    t.string "platforms", default: [], null: false, array: true
    t.index ["lockfile_id", "rails_release_id"], name: "index_lockfile_checks_on_lockfile_id_and_rails_release_id", unique: true
    t.index ["lockfile_id"], name: "index_lockfile_checks_on_lockfile_id"
    t.index ["rails_release_id"], name: "index_lockfile_checks_on_rails_release_id"
  end

  create_table "lockfile_dependencies", id: false, force: :cascade do |t|
    t.bigint "lockfile_id"
    t.bigint "gemmy_id"
  end

  create_table "lockfiles", force: :cascade do |t|
    t.text "content"
    t.text "slug"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
  end

  create_table "rails_releases", force: :cascade do |t|
    t.text "version"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
    t.string "minimum_ruby_version"
    t.string "minimum_bundler_version"
    t.string "minimum_rubygems_version"
    t.string "maximum_ruby_version"
    t.string "maximum_bundler_version"
    t.string "maximum_rubygems_version"
  end

  add_foreign_key "gem_checks", "lockfile_checks"
  add_foreign_key "inaccessible_gemmies", "lockfiles"
  add_foreign_key "lockfile_checks", "lockfiles"
  add_foreign_key "lockfile_checks", "rails_releases"
end
