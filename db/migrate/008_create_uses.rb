class CreateUses < ActiveRecord::Migration
  def self.up
    create_table :uses do |t|
      t.integer :project_id
      t.string :ontology
      t.timestamps
    end
  end

  def self.down
    drop_table :uses
  end
end
