# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key => '_bp_session',
  :secret => 'f8a5500d24178acfd38f883af2b2c16'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with 'rake db:sessions:create')
# ActionController::Base.session_store = :active_record_store
ActionController::Base.session_store = :mem_cache_store
