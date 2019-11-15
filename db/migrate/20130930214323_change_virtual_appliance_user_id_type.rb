class ChangeVirtualApplianceUserIdType < ActiveRecord::Migration[4.2]
  def self.up
    change_column :virtual_appliance_users, :user_id, :string
  end

  def self.down
    change_column :virtual_appliance_users, :user_id, :integer
  end
end
