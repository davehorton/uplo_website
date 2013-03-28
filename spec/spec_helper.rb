require 'rubygems'
require 'spork'

unless ENV['SEMAPHORE']
  require 'simplecov'
  SimpleCov.start do
    add_group "Models", "app/models"
  end
end

Spork.prefork do

  begin
    Spork.trap_method(Rails::Application::RoutesReloader, :reload!)
  rescue
  end

  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'capybara/rspec'
  require 'capybara/rails'
  require 'database_cleaner'
  require 'sidekiq/testing/inline'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  Capybara.configure do |config|
    config.default_selector  = :css
    config.default_wait_time = 1
  end

  # quieter logger
#  Rails.logger.level = 4

  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    #config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = false

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    config.include Aliases
    config.include Capybara::DSL
    config.include Devise::TestHelpers, :type => :controller
    config.include FactoryGirl::Syntax::Methods
    config.include Warden::Test::Helpers
    config.include IntegrationHelpers

    config.before(:suite) do
      DatabaseCleaner.clean_with(:truncation)
    end

    config.before(:each) do
      DatabaseCleaner.strategy = :transaction
    end

    config.before(:each, :js => true) do
      DatabaseCleaner.strategy = :truncation
    end

    config.before(:each) do
      DatabaseCleaner.start
      Warden.test_mode!
    end

    config.after(:each) do
      DatabaseCleaner.clean
      Capybara.reset_sessions!
      Warden.test_reset!
    end
  end
end

Spork.each_run do

  # disable all observers
  ActiveRecord::Base.observers.disable :all

end
