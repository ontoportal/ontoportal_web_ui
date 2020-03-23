class License < ApplicationRecord

  attr_reader :appliance_id, :organization, :expiry_date

  validates :encrypted_key, presence: true

  after_find :decrypt
  after_commit :decrypt

  def is_trial?
    encrypted_key == 'trial'
  end

  def days_remaining
    (@expiry_date < Date.current) ? 0 : (@expiry_date - Date.current).to_i
  end

  private

  def decrypt
    if is_trial?
      @expiry_date = created_at.to_date + 30.days
    else
      decrypted_key = LicenseKeyDecrypter.call(encrypted_key)
      license_data = decrypted_key.split(';')
      @appliance_id = license_data[0]
      @organization = license_data[1]
      @expiry_date = Date.parse(license_data[2])
    end  
  end

end
