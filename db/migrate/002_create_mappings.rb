class CreateMappings < ActiveRecord::Migration
  def self.up
    create_table :mappings do |t|
      t.integer :user_id
      t.string :source_id, :destination_id, :map_type, :source_ont, :destination_ont
      t.timestamps
    end
  end

  def self.down
    drop_table :mappings
  end
end
