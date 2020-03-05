require 'rails_helper'

RSpec.describe License, type: :model do

  include ActiveSupport::Testing::TimeHelpers

  let (:encrypted_license_key) { 
    <<~HEREDOC
      ds938nK0sdu8AzhtGefz0r7JTH97ncQfuokmwYLGHYbQF4CA1lWVHWwWoM/W\
      lzvZlDSE/WSLvXKefOXk6+yrelKgUMcnLy1Q5o6E+jJW6uia77Ivv6Hxl445\
      0kB8CeywyTTOQhROvQZ9NGsl5hpriNlaNlZHqo7gVtBZReoDypciUS+562On\
      x+CiYKl18bCOD7LmlJCyGg662EUPX5gwGORxKYYs/+tQixQ49LTg8dI/XguK\
      r/FIqUuz4erA73Le4Jn2C3dE2KjvS15DKIzwYL18oe+eONAPGj4JOredwk76\
      jHGa5fHNAmoSOB3jF6sboQK8nG/LajuFEI+O6fWXUQ==\
      |a6Bh755yqiviJBFm/XAMS/lA1hhYjR5SKrnQ5vb4/osMutu91j9Z/BSNIknD\
      Ia5kNAhlV6Ie0UkjjMbRgAr471TdLFcy2fB05BwG14JU1GM=
    HEREDOC
  }  
  # Decryption of above variable: "841b4f58-02e1-4a66-9e27-191f15e16279;Microsoft Corporation;2021-02-14".

  it do "decrypts license data"
    license = License.new(encrypted_key: encrypted_license_key)

    expect(license.appliance_id).to eq("841b4f58-02e1-4a66-9e27-191f15e16279")
    expect(license.organization).to eq("Microsoft Corporation")
    expect(license.expiry_date).to eq(Date.parse("2021-02-14"))
  end

  it do "is a trial license"
    license = License.new(encrypted_key: "trial", created_at: Time.current)

    expect(license.is_trial?).to eq(true)
  end

  it do "is not a trial license"
    license = License.new(encrypted_key: encrypted_license_key)

    expect(license.is_trial?).to eq(false)
  end

  it do "is in trial period"
    license = License.new(encrypted_key: "trial", created_at: Time.current)
    
    travel 15.days do
      expect(license.days_remaining).to be > 0
    end
  end

  it do "is out of trial after trial period"
    license = License.new(encrypted_key: "trial", created_at: Time.current)

    travel 31.days do
      expect(license.days_remaining).to eq(0)
    end
  end

  it do "calculates days remaining"
    license = License.new(encrypted_key: encrypted_license_key)

    travel_to(Date.parse("2021-01-15")) do
      expect(license.days_remaining).to eq(30)
    end

    travel_to(Date.parse("2021-02-13")) do
      expect(license.days_remaining).to eq(1)
    end

    travel_to(Date.parse("2021-02-14")) do
      expect(license.days_remaining).to eq(0)
    end

    travel_to(Date.parse("2021-03-01")) do
      expect(license.days_remaining).to eq(0)
    end
  end

end
