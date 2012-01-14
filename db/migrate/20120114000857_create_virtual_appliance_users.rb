class CreateVirtualApplianceUsers < ActiveRecord::Migration
  def self.up
    create_table :virtual_appliance_users do |t|
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :virtual_appliance_users
  end
end
