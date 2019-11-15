class CreateMappings < ActiveRecord::Migration[4.2]
  def self.up
    create_table :mappings do |t|
      t.integer :user_id,:source_ont,:destination_ont,:source_version_id,:destination_version_id
      t.string :source_id, :destination_id, :map_type, :source_ont, :destination_ont,:map_source,:relationship_type,:source_name,:destination_name,:source_ont_name,:destination_ont_name
      t.text :comment
      t.timestamps
    end
  end

  def self.down
    drop_table :mappings
  end
end
