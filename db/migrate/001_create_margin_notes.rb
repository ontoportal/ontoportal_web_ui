class CreateMarginNotes < ActiveRecord::Migration[4.2]
  def self.up
    create_table :margin_notes do |t|
      t.integer :parent_id, :mapping_id, :note_type,:user_id, :ontology_id, :ontology_version_id
      t.string :concept_id, :subject
      t.text :comment
      t.timestamps
    end
  end

  def self.down
    drop_table :margin_notes
  end
end
