class CreateEventItems < ActiveRecord::Migration[4.2]
  def self.up
    create_table "event_items", :force => true do |t|
      t.string   "event_type",    :limit => 50
      t.integer  "event_type_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "ontology_id"
    end
  end

  def self.down
    drop_table "event_items"
  end
end
