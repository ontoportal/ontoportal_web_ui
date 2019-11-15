class AddSurvey < ActiveRecord::Migration[4.2]
  def self.up
    create_table "surveys" do |t|
      t.column "user_id", :integer
      t.column "survey_completed", :integer
      t.column "organization", :string
      t.column "project_name", :string
      t.column "project_url", :string
      t.column "project_description", :text
      t.column "read_access_ui", :boolean
      t.column "create_notes_ui", :boolean
      t.column "create_mappings_ui", :boolean
      t.column "annotate_ui", :boolean
      t.column "resource_index_ui", :boolean
      t.column "read_access_rest", :boolean
      t.column "notes_rest", :boolean
      t.column "mappings_rest", :boolean
      t.column "annotate_rest", :boolean
      t.column "resource_index_rest", :boolean
      t.column "ontologies_of_interest", :string
    end
  end

  def self.down
    drop_table "surveys"
  end
end
