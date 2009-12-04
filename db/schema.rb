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

  create_table "event_items", :force => true do |t|
    t.string   "event_type",    :limit => 50
    t.integer  "event_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ontology_id"
  end

  create_table "mappings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "source_ont",             :limit => 255
    t.integer  "destination_ont",        :limit => 255
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
    t.integer  "mapping_id"
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

  create_table "widget_logs", :force => true do |t|
    t.integer "count",   :limit => 50, :default => 0, :null => false
    t.string  "widget",  :limit => 50
    t.string  "referer"
  end

end
