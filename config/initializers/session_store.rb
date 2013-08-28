# Be sure to restart your server when you modify this file.

if Rails.env.production?
  Uplo::Application.config.session_store :cookie_store, key: '_uplo_com_session', :domain => 'uplo.com', :expire_after => 1.year
else
  Uplo::Application.config.session_store :cookie_store, key: '_uplo_com_session', :domain => :all, :expire_after => 1.year
end

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Uplo::Application.config.session_store :active_record_store
