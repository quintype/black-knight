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

ActiveRecord::Schema.define(version: 20170721084104) do

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

  create_table "admin_users", force: :cascade do |t|
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
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "name"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true

  create_table "audits", force: :cascade do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         default: 0
    t.string   "comment"
    t.string   "remote_address"
    t.string   "request_uuid"
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], name: "associated_index"
  add_index "audits", ["auditable_id", "auditable_type"], name: "auditable_index"
  add_index "audits", ["created_at"], name: "index_audits_on_created_at"
  add_index "audits", ["request_uuid"], name: "index_audits_on_request_uuid"
  add_index "audits", ["user_id", "user_type"], name: "user_index"

  create_table "clusters", force: :cascade do |t|
    t.string   "name",            null: false
    t.string   "kube_api_server", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "config_files", force: :cascade do |t|
    t.integer  "deploy_environment_id"
    t.string   "path",                  null: false
    t.text     "value",                 null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.date     "deleted_at"
  end

  add_index "config_files", ["deploy_environment_id"], name: "index_config_files_on_deploy_environment_id"

  create_table "deploy_environments", force: :cascade do |t|
    t.integer  "publisher_id"
    t.string   "name",         null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "app_name"
    t.string   "repository"
    t.boolean  "disposable"
    t.integer  "cluster_id"
  end

  add_index "deploy_environments", ["cluster_id"], name: "index_deploy_environments_on_cluster_id"
  add_index "deploy_environments", ["publisher_id"], name: "index_deploy_environments_on_publisher_id"

  create_table "deployments", force: :cascade do |t|
    t.integer  "deploy_environment_id"
    t.string   "status",                null: false
    t.string   "version",               null: false
    t.text     "configuration",         null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "deploy_tag"
    t.datetime "build_started"
    t.datetime "build_ended"
    t.string   "build_status"
    t.text     "build_output"
    t.datetime "deploy_started"
    t.datetime "deploy_ended"
    t.string   "deploy_status"
    t.text     "deploy_output"
    t.integer  "scheduled_by_id"
    t.datetime "cancelled_at"
    t.integer  "cancelled_by_id"
    t.integer  "redeploy_of_id"
  end

  add_index "deployments", ["deploy_environment_id"], name: "index_deployments_on_deploy_environment_id"
  add_index "deployments", ["redeploy_of_id"], name: "index_deployments_on_redeploy_of_id"

  create_table "publishers", force: :cascade do |t|
    t.integer  "quintype_id_of_publisher", null: false
    t.string   "name",                     null: false
    t.string   "admin_email",              null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "username"
  end

  create_table "user_publishers", force: :cascade do |t|
    t.integer  "publisher_id"
    t.integer  "user_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "user_publishers", ["publisher_id"], name: "index_user_publishers_on_publisher_id"
  add_index "user_publishers", ["user_id"], name: "index_user_publishers_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "email",                     default: "", null: false
    t.string   "encrypted_password",        default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",             default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "name"
    t.boolean  "super_user"
    t.string   "encrypted_otp_secret"
    t.string   "encrypted_otp_secret_iv"
    t.string   "encrypted_otp_secret_salt"
    t.boolean  "otp_required_for_login"
    t.string   "unconfirmed_otp_secret"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
