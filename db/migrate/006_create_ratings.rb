class CreateRatings < ActiveRecord::Migration[4.2]
  def self.up
    create_table :ratings do |t|
      t.integer :rating_type_id, :value, :review_id
      t.timestamps
    end
  end

  def self.down
    drop_table :ratings
  end
end
