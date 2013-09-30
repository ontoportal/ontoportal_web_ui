class ChangeVirtualApplianceUserIdType < ActiveRecord::Migration
  def self.up
    change_column :virtual_appliance_users, :user_id, :string
  end

  def self.down
    change_column :virtual_appliance_users, :user_id, :integer
  end
end
