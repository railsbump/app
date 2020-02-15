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
    t.boolean "compatible"
    t.bigint "rails_release_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "checked_at"
    t.jsonb "dependencies", default: {}
    t.index ["rails_release_id"], name: "index_compats_on_rails_release_id"
  end

  create_table "gemfile_dependencies", id: false, force: :cascade do |t|
    t.bigint "gemfile_id"
    t.bigint "gemmy_id"
    t.index ["gemfile_id"], name: "index_gemfile_dependencies_on_gemfile_id"
    t.index ["gemmy_id"], name: "index_gemfile_dependencies_on_gemmy_id"
  end

  create_table "gemfiles", force: :cascade do |t|
    t.text "content"
    t.string "slug"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["slug"], name: "index_gemfiles_on_slug", unique: true
  end

  create_table "gemmies", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "dependencies_and_versions", default: {}
    t.index ["name"], name: "index_gemmies_on_name", unique: true
  end

  create_table "rails_releases", force: :cascade do |t|
    t.string "version"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["version"], name: "index_rails_releases_on_version", unique: true
  end

  create_table "travis_notifications", force: :cascade do |t|
    t.jsonb "data"
    t.datetime "processed_at"
    t.bigint "compat_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["compat_id"], name: "index_travis_notifications_on_compat_id"
  end

end
