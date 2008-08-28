# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 8) do

  create_table "mappings", :force => true do |t|
    t.integer  "user_id"
    t.string   "source_id"
    t.string   "destination_id"
    t.string   "map_type"
    t.string   "source_ont"
    t.string   "destination_ont"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "map_source",      :limit => 50
  end

  create_table "margin_notes", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "mapping_id"
    t.integer  "note_type"
    t.integer  "user_id"
    t.string   "concept_id"
    t.string   "subject"
    t.string   "ontology_id"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ncbc_softwares", :force => true do |t|
    t.string "name",           :limit => 50
    t.text   "description"
    t.string "keywords"
    t.string "authors"
    t.string "ontology_label"
    t.string "organization"
    t.string "url"
    t.string "data_input"
    t.string "data_output"
    t.string "resource_type"
    t.string "rls_version"
    t.string "license"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.string   "institution"
    t.string   "people"
    t.string   "homepage"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "rating_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ratings", :force => true do |t|
    t.integer  "rating_type_id"
    t.integer  "value"
    t.integer  "review_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reviews", :force => true do |t|
    t.integer  "user_id"
    t.string   "ontology"
    t.text     "review"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone"
    t.string   "user_name"
    t.string   "hashed_password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin"
  end

  create_table "uses", :force => true do |t|
    t.integer  "project_id"
    t.string   "ontology"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
