class ChangeMappingIdColumnType < ActiveRecord::Migration[4.2]
  def self.up
    change_column :margin_notes, :mapping_id, :string
  end

  def self.down
    change_column :margin_notes, :mapping_id, :integer
  end
end
