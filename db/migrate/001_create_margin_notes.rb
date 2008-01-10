class CreateMarginNotes < ActiveRecord::Migration
  def self.up
    create_table :margin_notes do |t|
      t.integer :parent_id, :mapping_id, :note_type,:user_id
      t.string :concept_id, :subject, :ontology_id
      t.text :comment
      t.timestamps
    end
  end

  def self.down
    drop_table :margin_notes
  end
end
