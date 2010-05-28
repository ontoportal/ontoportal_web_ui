class CreateNotes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|
      t.string :subject
      t.text :body
      t.string :author
      t.boolean :archived
      t.string :hasStatus
      t.integer :ontology_id
      t.string :concept_id
      t.integer :annotates
      t.text :annotated_by

      t.timestamps
    end
  end

  def self.down
    drop_table :notes
  end
end
