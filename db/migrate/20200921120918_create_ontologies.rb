class CreateOntologies < ActiveRecord::Migration[5.1]
  def change
    create_table :ontologies do |t|
      t.string :acronym, null: false
      t.text :new_term_instructions
      t.text :custom_message

      t.timestamps
    end

    add_index :ontologies, :acronym, unique: true
  end
end
