class AddWidgetsUiToSurveys < ActiveRecord::Migration[4.2]
  def self.up
    add_column :surveys, :widgets_ui, :boolean
  end

  def self.down
    remove_column :surveys, :widgets_ui
  end
end
