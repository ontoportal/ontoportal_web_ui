class CreateCustomOntologies < ActiveRecord::Migration[4.2]
  def self.up
    create_table :custom_ontologies do |t|
      t.integer :user_id
      t.text :ontologies

      t.timestamps
    end
  end

  def self.down
    drop_table :custom_ontologies
  end
end
