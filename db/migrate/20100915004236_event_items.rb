class EventItems < ActiveRecord::Migration
  def self.up
    change_column(:event_items, :event_type_id, :string, :limit => 255)
  end

  def self.down
    change_column(:event_items, :event_type_id, :integer, :limit => 11)
  end
end
