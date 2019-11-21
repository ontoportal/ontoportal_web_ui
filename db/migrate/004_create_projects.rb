class CreateProjects < ActiveRecord::Migration[4.2]
  def self.up
    create_table :projects do |t|
      t.string :name, :institution, :people, :homepage
      t.text :description
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :projects
  end
end
