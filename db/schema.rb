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

ActiveRecord::Schema.define(:version => 2) do

  create_table "mappings", :force => true do |t|
    t.integer  "user_id"
    t.string   "source_id"
    t.string   "destination_id"
    t.string   "map_type"
    t.string   "source_ont"
    t.string   "destination_ont"
    t.datetime "created_at"
    t.datetime "updated_at"
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

end
