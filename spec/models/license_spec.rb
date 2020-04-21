require 'rails_helper'

RSpec.describe License, type: :model do

  include ActiveSupport::Testing::TimeHelpers

  # Decryption of below variable: "841b4f58-02e1-4a66-9e27-191f15e16279;Microsoft Corporation;2021-02-14".
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

  # This license key was generated using the staging license server, and the 
  # encoded appliance ID matches that of the BioPortal staging environment.
  # 
  # Staging license server: https://license.stage.ontoportal.org
  # Staging BioPortal instance: https://stage.bioontology.org/
  # License information for this encrypted key: https://license.stage.ontoportal.org/licenses/1077
  #
  # Decryption of below variable: "dd212a7c-29fd-4142-8353-f59a19a79738;BMIR;2021-04-20"
  #
  let (:encrypted_license_key_staging_env) {
    <<~HEREDOC
      WtlzkakMaAKx7NwyuHRnCDVSMQszaEtv7jNiVgBcg9kQeNS69ToFp9Nhvb8F
      AANaHtSibb6InYemQABpq+sONg9cp4+pfCTAh5ETmyF8GPrWiwv8DZstMRUO
      IL0ws37nFZON8kYyFvWguiqL6U55r6ghaiCpI1tdfelujF4uThMbSQYI+gcN
      UdElYm3lO2HNtEdSQ6Z3JeVZ7DtTGcGW9xKVOd1Nefoq+oDwRZ+z2JyMLtfK
      xckDRKxzAKBhV43DS64dPXz9xAJwbLTWsGVofwN/1BTQRwimS8V4/Tc0vjha
      2H5KyOVIGu1XNfEnIJ0Rbh9SiHflmT0T7JTNFIivNA==
      |Sf6udPHZJB3CSRQBRw8CjB4nHEspfpg4fM7NwStIfXhfiDx0W0P0+9NiQkIh
      0VlkhKD3ev0hnSDi/x/GazByvg==
    HEREDOC
  }

  it do "decrypts license data"
    license = License.create(encrypted_key: encrypted_license_key_staging_env)

    expect(license.appliance_id).to eq("dd212a7c-29fd-4142-8353-f59a19a79738")
    expect(license.organization).to eq("BMIR")
    expect(license.expiry_date).to eq(Date.parse("2021-04-20"))
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
    license = License.create(encrypted_key: encrypted_license_key_staging_env)

    travel_to(Date.parse("2021-03-21")) do
      expect(license.days_remaining).to eq(30)
    end

    travel_to(Date.parse("2021-04-19")) do
      expect(license.days_remaining).to eq(1)
    end

    travel_to(Date.parse("2021-04-20")) do
      expect(license.days_remaining).to eq(0)
    end

    travel_to(Date.parse("2021-05-01")) do
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
      license = License.new(encrypted_key: encrypted_license_key_staging_env)

      license.valid?

      expect(license).to be_valid
      expect(license.errors).to be_empty
    end

    it "blocks licenses with mismatches between encoded appliance IDs and actual" do
      license = License.new(encrypted_key: encrypted_license_key)

      license.save

      expect(license.errors[:encrypted_key]).to include "is an appliance ID mismatch"
    end

  end

  describe ".current_license" do

    it "should return the latest license" do
      new_license = License.create(encrypted_key: encrypted_license_key_staging_env, created_at: Time.now + 1.day)
      newer_license = License.create(encrypted_key: encrypted_license_key_staging_env, created_at: Time.now + 2.days)

      expect(License.current_license.count).to eql(1)
      expect(License.current_license.first).to eql(newer_license)
    end

  end

end
