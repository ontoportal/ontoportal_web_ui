class CreateLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :logs do |t|
      t.string :user
      t.string :ontology
      t.float :rating
      t.timestamp :time
    end
  end
end
