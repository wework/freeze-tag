
ENV['RAILS_ENV'] = 'test'
require "bundler/setup"
require "freeze_tag"
require "byebug"

require './spec/app/application.rb'
require 'database_cleaner'
require 'webmock/rspec'
require 'rails/all'
require 'rspec/rails'
require "action_controller/railtie"

module TestApplication
  class Application < Rails::Application
  end
end

Rails.application.routes.draw do
  root to: 'application#index'
end

class TestLogger < Logger
  def info
  end
end

Rails.logger = TestLogger.new(STDOUT)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.order = "random"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_doubled_constant_names = true
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

end