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

ActiveRecord::Schema[7.0].define(version: 2022_11_26_124039) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clients", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "nif"
    t.string "street"
    t.string "city"
    t.string "region"
    t.string "postal_code"
    t.string "country"
    t.string "email"
    t.string "telephone"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_clients_on_user_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.string "invoice_number"
    t.datetime "date"
    t.datetime "due_date"
    t.decimal "subtotal", default: "0.0"
    t.decimal "iva", default: "0.0"
    t.decimal "irpf", default: "0.0"
    t.decimal "total", default: "0.0"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "client_id"
    t.string "status"
    t.index ["client_id"], name: "index_invoices_on_client_id"
    t.index ["user_id"], name: "index_invoices_on_user_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "item_name"
    t.text "description"
    t.decimal "price", precision: 8, scale: 2
    t.decimal "iva"
    t.decimal "irpf"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "line_items", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.bigint "invoice_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "quantity", null: false
    t.index ["invoice_id"], name: "index_line_items_on_invoice_id"
    t.index ["item_id"], name: "index_line_items_on_item_id"
  end

  create_table "user_profiles", force: :cascade do |t|
    t.string "gov_id"
    t.string "street_address_1"
    t.string "street_address_2"
    t.string "city"
    t.string "region"
    t.string "postal_code"
    t.string "country"
    t.string "phone"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_freelance"
    t.string "company_name"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.index ["user_id"], name: "index_user_profiles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_profile_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.index ["user_profile_id"], name: "index_users_on_user_profile_id"
  end

  add_foreign_key "clients", "users"
  add_foreign_key "invoices", "users"
  add_foreign_key "items", "users"
  add_foreign_key "line_items", "invoices"
  add_foreign_key "line_items", "items"
  add_foreign_key "user_profiles", "users"
  add_foreign_key "users", "user_profiles"
end
