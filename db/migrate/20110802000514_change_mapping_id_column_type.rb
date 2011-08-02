class ChangeMappingIdColumnType < ActiveRecord::Migration
  def self.up
    change_column :margin_notes, :mapping_id, :string
  end

  def self.down
    change_column :margin_notes, :mapping_id, :integer
  end
end
