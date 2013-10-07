# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130930214323) do

  create_table "analytics", :force => true do |t|
    t.string   "segment"
    t.string   "action"
    t.string   "slice"
    t.string   "ip"
    t.integer  "user"
    t.text     "params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "custom_ontologies", :force => true do |t|
    t.integer  "user_id"
    t.text     "ontologies"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_items", :force => true do |t|
    t.string   "event_type",    :limit => 50
    t.string   "event_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ontology_id"
  end

  create_table "groups", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mappings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "source_ont"
    t.integer  "destination_ont"
    t.integer  "source_version_id"
    t.integer  "destination_version_id"
    t.string   "source_id"
    t.string   "destination_id"
    t.string   "map_type"
    t.string   "map_source"
    t.string   "relationship_type"
    t.string   "source_name"
    t.string   "destination_name"
    t.string   "source_ont_name"
    t.string   "destination_ont_name"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "margin_notes", :force => true do |t|
    t.integer  "parent_id"
    t.string   "mapping_id"
    t.integer  "note_type"
    t.integer  "user_id"
    t.integer  "ontology_id"
    t.integer  "ontology_version_id"
    t.string   "concept_id"
    t.string   "subject"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notes_indices", :force => true do |t|
    t.string   "note_id",                      :null => false
    t.integer  "ontology_id",                  :null => false
    t.integer  "author",                       :null => false
    t.string   "note_type",                    :null => false
    t.string   "subject",                      :null => false
    t.string   "applies_to",                   :null => false
    t.string   "applies_to_type",              :null => false
    t.text     "body"
    t.integer  "created",         :limit => 8, :null => false
    t.datetime "timestamp"
  end

  add_index "notes_indices", ["note_id"], :name => "note_id", :unique => true

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.string   "institution"
    t.string   "people"
    t.string   "homepage"
    t.text     "description"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.integer  "ontology_id"
    t.integer  "project_id"
    t.text     "review"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "surveys", :force => true do |t|
    t.integer "user_id"
    t.integer "survey_completed"
    t.string  "organization"
    t.string  "project_name"
    t.string  "project_url"
    t.text    "project_description"
    t.boolean "read_access_ui"
    t.boolean "create_notes_ui"
    t.boolean "create_mappings_ui"
    t.boolean "annotate_ui"
    t.boolean "resource_index_ui"
    t.boolean "read_access_rest"
    t.boolean "notes_rest"
    t.boolean "mappings_rest"
    t.boolean "annotate_rest"
    t.boolean "resource_index_rest"
    t.string  "ontologies_of_interest"
    t.boolean "widgets_ui"
  end

  create_table "timeouts", :force => true do |t|
    t.string   "path"
    t.integer  "ontology_id"
    t.text     "concept_id"
    t.text     "params"
    t.datetime "created"
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone"
    t.string   "user_name"
    t.string   "hashed_password"
    t.boolean  "admin"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "uses", :force => true do |t|
    t.integer  "project_id"
    t.integer  "ontology_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "virtual_appliance_users", :force => true do |t|
    t.string   "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "widget_logs", :force => true do |t|
    t.integer "count",                 :default => 0, :null => false
    t.string  "widget",  :limit => 50
    t.string  "referer"
  end

end
