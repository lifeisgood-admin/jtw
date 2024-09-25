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

ActiveRecord::Schema.define(version: 2024_09_24_034655) do

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "jobs", force: :cascade do |t|
    t.integer "partner_id"
    t.text "movie_url"
    t.text "title"
    t.text "main_content"
    t.text "free_comment"
    t.text "background"
    t.text "job_fun"
    t.text "qualification"
    t.text "preferable_exp"
    t.text "hire_num"
    t.integer "min_age"
    t.integer "max_age"
    t.text "age_reason"
    t.string "emp_status"
    t.text "trial_period"
    t.text "work_time"
    t.text "work_location"
    t.text "pref"
    t.text "city"
    t.text "street"
    t.text "station"
    t.text "income"
    t.string "income_style"
    t.integer "min_income"
    t.integer "max_income"
    t.text "treatment"
    t.text "holiday"
    t.text "work_place_note"
    t.text "selection_process"
    t.string "free_title1"
    t.text "free_content1"
    t.string "free_title2"
    t.text "free_content2"
    t.string "free_title3"
    t.text "free_content3"
    t.string "label"
    t.text "search_job"
    t.text "search_feature"
    t.text "search_location"
    t.integer "disclose_flg"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "partners", force: :cascade do |t|
    t.string "name"
    t.text "category"
    t.text "map_url"
    t.string "url"
    t.text "privacy_policy"
    t.text "label"
    t.string "main_image_position"
    t.text "catch_copy"
    t.string "catch_copy_color"
    t.string "catch_copy_position"
    t.string "main_color"
    t.text "contact_mail"
    t.text "contact_tel"
    t.text "contact_line"
    t.text "contact_x"
    t.text "contact_fb"
    t.text "contact_linkedin"
    t.text "contact_insta"
    t.string "info1_item"
    t.string "info2_item"
    t.string "info3_item"
    t.string "info4_item"
    t.string "info5_item"
    t.string "info6_item"
    t.string "info7_item"
    t.string "info8_item"
    t.string "info9_item"
    t.string "info10_item"
    t.text "info1_content"
    t.text "info2_content"
    t.text "info3_content"
    t.text "info4_content"
    t.text "info5_content"
    t.text "info6_content"
    t.text "info7_content"
    t.text "info8_content"
    t.text "info9_content"
    t.text "info10_content"
    t.integer "disclose_flg"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "mail"
  end

  create_table "posts", force: :cascade do |t|
    t.integer "partner_id"
    t.text "category"
    t.string "title"
    t.text "description"
    t.string "index_type"
    t.text "movie_url"
    t.string "item1_label"
    t.text "item1_content"
    t.string "item1_position"
    t.string "item1_image_alt"
    t.text "item1_movie_url"
    t.string "item2_label"
    t.text "item2_content"
    t.string "item2_position"
    t.string "item2_image_alt"
    t.text "item2_movie_url"
    t.string "item3_label"
    t.text "item3_content"
    t.string "item3_position"
    t.string "item3_image_alt"
    t.text "item3_movie_url"
    t.string "item4_label"
    t.text "item4_content"
    t.string "item4_position"
    t.string "item4_image_alt"
    t.text "item4_movie_url"
    t.string "item5_label"
    t.text "item5_content"
    t.string "item5_position"
    t.string "item5_image_alt"
    t.text "item5_movie_url"
    t.string "item6_label"
    t.text "item6_content"
    t.string "item6_position"
    t.string "item6_image_alt"
    t.text "item6_movie_url"
    t.string "item7_label"
    t.text "item7_content"
    t.string "item7_position"
    t.string "item7_image_alt"
    t.text "item7_movie_url"
    t.string "item8_label"
    t.text "item8_content"
    t.string "item8_position"
    t.string "item8_image_alt"
    t.text "item8_movie_url"
    t.integer "disclose_flg"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "topic_categories", force: :cascade do |t|
    t.integer "partner_id"
    t.string "name"
    t.string "subscript"
    t.text "description"
    t.integer "display_order"
    t.string "content_type"
    t.string "display_style"
    t.text "movie_url"
    t.string "menu_name"
    t.integer "disclose_flg"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "topics", force: :cascade do |t|
    t.integer "topic_category_id"
    t.string "title"
    t.text "description"
    t.string "index_type"
    t.text "movie_url"
    t.string "item1_label"
    t.text "item1_content"
    t.string "item1_position"
    t.string "item1_image_alt"
    t.text "item1_movie_url"
    t.string "item2_label"
    t.text "item2_content"
    t.string "item2_position"
    t.string "item2_image_alt"
    t.text "item2_movie_url"
    t.string "item3_label"
    t.text "item3_content"
    t.string "item3_position"
    t.string "item3_image_alt"
    t.text "item3_movie_url"
    t.string "item4_label"
    t.text "item4_content"
    t.string "item4_position"
    t.string "item4_image_alt"
    t.text "item4_movie_url"
    t.string "item5_label"
    t.text "item5_content"
    t.string "item5_position"
    t.string "item5_image_alt"
    t.text "item5_movie_url"
    t.string "item6_label"
    t.text "item6_content"
    t.string "item6_position"
    t.string "item6_image_alt"
    t.text "item6_movie_url"
    t.string "item7_label"
    t.text "item7_content"
    t.string "item7_position"
    t.string "item7_image_alt"
    t.text "item7_movie_url"
    t.string "item8_label"
    t.text "item8_content"
    t.string "item8_position"
    t.string "item8_image_alt"
    t.text "item8_movie_url"
    t.integer "display_order"
    t.integer "disclose_flg"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.integer "partner_id"
    t.boolean "admin_flg"
    t.string "name"
    t.string "mail"
    t.string "password_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
