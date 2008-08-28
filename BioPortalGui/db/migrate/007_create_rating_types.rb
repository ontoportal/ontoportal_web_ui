class CreateRatingTypes < ActiveRecord::Migration
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
