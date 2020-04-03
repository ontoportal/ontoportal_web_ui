class EventItems < ActiveRecord::Migration[4.2]
  def self.up
    change_column(:event_items, :event_type_id, :string, :limit => 255)
  end

  def self.down
    change_column(:event_items, :event_type_id, :integer, :limit => 11)
  end
end
