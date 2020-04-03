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
    license = License.create(encrypted_key: encrypted_license_key)

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
    license = License.create(encrypted_key: "trial", created_at: Time.current)
    
    travel 15.days do
      expect(license.days_remaining).to be > 0
    end
  end

  it do "is out of trial after trial period"
    license = License.create(encrypted_key: "trial", created_at: Time.current)

    travel 31.days do
      expect(license.days_remaining).to eq(0)
    end
  end

  it do "calculates days remaining"
    license = License.create(encrypted_key: encrypted_license_key)

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

  describe "validation" do

    let (:encrypted_license_key_with_missing_characters) { 
      <<~HEREDOC
        ds938nK0sdu8AzhtGefz0r7JTH97ncQfuokmwYLGHYbQF4CA1lWVHWwWoM/W\
        lzvZlDSE/WSLvXKefOXk6+yrelKgUMcnLy1Q5o6E+jJW6uia77Ivv6Hxl445\
        0kB8CeywyTTOQhROvQZ9NGsl5hpriNlaNlZHqo7gVtBZReoDypciUS+562On\
        x+CiYKl18bCOD7LmlJCyGg662EUPX5gwGORxKYYs/+tQixQ49LTg8dI/XguK\
        r/FIqUuz4erA73Le4Jn2C3dE2KjvS15DKIzwYL18oe+eONAPGj4JOredwk76\
        jHGa5fHNAmoSOB3jF6sboQK8nG/LajuFEI+O6fWXUQ==\
        |a6Bh755yqiviJBFm/XAMS/lA1hhYjR5SKrnQ5vb4/osMutu91j9Z/BSNIknD\
        Ia5kNAhlV6Ie0UkjjMbRgAr471TdLFcy2fB05BwG14JU
      HEREDOC
    }  

    it "blocks malformed keys" do
      license = License.new(encrypted_key: encrypted_license_key_with_missing_characters)

      license.valid?

      expect(license).to be_invalid
      expect(license.errors[:encrypted_key]).to include I18n.t("activerecord.errors.models.license.attributes.encrypted_key.invalid_license_key")
    end

    it "blocks invalid keys" do
      license = License.create(encrypted_key: "lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua")

      license.valid?

      expect(license).to be_invalid
      expect(license.errors[:encrypted_key]).to include I18n.t("activerecord.errors.models.license.attributes.encrypted_key.invalid_license_key")
    end

    it "allows trial licenses" do
      license = License.new(encrypted_key: "trial")

      license.valid?

      expect(license).to be_valid
      expect(license.errors).to be_empty
    end

    it "allows valid keys" do
      license = License.new(encrypted_key: encrypted_license_key)

      license.valid?

      expect(license).to be_valid
      expect(license.errors).to be_empty
    end

  end

  describe ".current_license" do

    it "should return the latest license" do
      new_license = License.create(encrypted_key: encrypted_license_key, created_at: Time.now + 1.day)
      newer_license = License.create(encrypted_key: encrypted_license_key, created_at: Time.now + 2.days)

      expect(License.current_license.count).to eql(1)
      expect(License.current_license.first).to eql(newer_license)
    end

  end

end
