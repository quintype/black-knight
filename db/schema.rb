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

ActiveRecord::Schema.define(version: 20160324115435) do

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.string   "author_type"
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"

  create_table "config_files", force: :cascade do |t|
    t.integer  "deploy_environment_id"
    t.string   "path",                  null: false
    t.text     "value",                 null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "config_files", ["deploy_environment_id"], name: "index_config_files_on_deploy_environment_id"

  create_table "deploy_environments", force: :cascade do |t|
    t.integer  "publisher_id"
    t.string   "name",         null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "deploy_environments", ["publisher_id"], name: "index_deploy_environments_on_publisher_id"

  create_table "deployments", force: :cascade do |t|
    t.integer  "deploy_environment_id"
    t.string   "status",                null: false
    t.string   "version",               null: false
    t.text     "configuration",         null: false
    t.text     "output"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "deployments", ["deploy_environment_id"], name: "index_deployments_on_deploy_environment_id"

  create_table "publishers", force: :cascade do |t|
    t.integer  "quintype_id_of_publisher", null: false
    t.string   "name",                     null: false
    t.string   "admin_email",              null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

end
