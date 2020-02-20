class License < ApplicationRecord

	validates :encrypted_key, presence: true

end
