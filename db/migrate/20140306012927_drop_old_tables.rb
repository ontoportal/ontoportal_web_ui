class DropOldTables < ActiveRecord::Migration
  def self.up
    drop_table :custom_ontologies
    drop_table :event_items
    drop_table :groups
    drop_table :mapping_import_errors
    drop_table :mappings
    drop_table :margin_notes
    drop_table :notes
    drop_table :notes_indices
    drop_table :projects
    drop_table :rating_types
    drop_table :ratings
    drop_table :reviews
    drop_table :surveys
    drop_table :users
    drop_table :uses
    drop_table :widget_logs
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
