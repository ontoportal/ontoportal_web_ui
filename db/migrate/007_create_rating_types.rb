class CreateRatingTypes < ActiveRecord::Migration[4.2]
  def self.up
    create_table :rating_types do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :rating_types
  end
end
