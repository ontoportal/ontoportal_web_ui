ActiveSupport.on_load(:active_record) do

  # Setup a trial license for blank installs of the virtual appliance
  unless License.where(encrypted_key: 'trial').exists?
    License.create(encrypted_key: 'trial', created_at: Time.current)
  end

end
