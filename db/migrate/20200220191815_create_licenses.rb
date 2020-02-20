class CreateLicenses < ActiveRecord::Migration[5.1]
  def change
    create_table :licenses do |t|
      t.text :encrypted_key

      t.timestamps
    end
  end
end
