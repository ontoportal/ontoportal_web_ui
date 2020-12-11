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

ActiveRecord::Schema.define(version: 2020_09_21_120918) do

  create_table "analytics", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "segment"
    t.string "action"
    t.string "bp_slice"
    t.string "ip"
    t.integer "user"
    t.text "params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "licenses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "encrypted_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ontologies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "acronym", null: false
    t.text "new_term_instructions"
    t.text "custom_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["acronym"], name: "index_ontologies_on_acronym", unique: true
  end

  create_table "timeouts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "path"
    t.integer "ontology_id"
    t.text "concept_id"
    t.text "params"
    t.timestamp "created"
  end

  create_table "virtual_appliance_users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
