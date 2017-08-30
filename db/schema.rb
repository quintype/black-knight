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

ActiveRecord::Schema.define(version: 20170828204329) do

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.string   "author_type"
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

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
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

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
    t.index ["associated_id", "associated_type"], name: "associated_index"
    t.index ["auditable_id", "auditable_type"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

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
    t.index ["deploy_environment_id"], name: "index_config_files_on_deploy_environment_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "deploy_environments", force: :cascade do |t|
    t.integer  "publisher_id"
    t.string   "name",         null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "app_name"
    t.string   "repository"
    t.boolean  "disposable"
    t.integer  "cluster_id"
    t.boolean  "migratable"
    t.index ["cluster_id"], name: "index_deploy_environments_on_cluster_id"
    t.index ["publisher_id"], name: "index_deploy_environments_on_publisher_id"
  end

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
    t.index ["deploy_environment_id"], name: "index_deployments_on_deploy_environment_id"
    t.index ["redeploy_of_id"], name: "index_deployments_on_redeploy_of_id"
  end

  create_table "migrations", force: :cascade do |t|
    t.text     "migration_command"
    t.integer  "deploy_environment_id"
    t.string   "status"
    t.string   "version"
    t.text     "configuration"
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
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "publishers", force: :cascade do |t|
    t.integer  "quintype_id_of_publisher", null: false
    t.string   "name",                     null: false
    t.string   "admin_email",              null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.text     "username"
  end

  create_table "user_publishers", force: :cascade do |t|
    t.integer  "publisher_id"
    t.integer  "user_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["publisher_id"], name: "index_user_publishers_on_publisher_id"
    t.index ["user_id"], name: "index_user_publishers_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                                default: "", null: false
    t.string   "encrypted_password",                   default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        default: 0,  null: false
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
    t.integer  "consumed_timestep"
    t.boolean  "unconfirmed_mfa"
    t.string   "authentication_token",      limit: 30
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
