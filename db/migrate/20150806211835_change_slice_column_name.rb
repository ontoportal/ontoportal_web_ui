class ChangeSliceColumnName < ActiveRecord::Migration[4.2]
  def change
    rename_column :analytics, :slice, :bp_slice
  end
end
