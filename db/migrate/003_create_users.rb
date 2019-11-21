class CreateUsers < ActiveRecord::Migration[4.2]
  def self.up
    create_table :users do |t|
      t.string :first_name, :last_name, :email, :phone, :user_name,:hashed_password
      t.boolean :admin
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
