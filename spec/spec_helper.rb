require 'rubygems'
require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require "steak"
  require 'capybara/rspec'
  require 'capybara/rails'
  require 'selenium-webdriver'
  require 'rspec/core/expecting/with_rspec'
  require 'rspec/core/formatters/base_text_formatter'
  require 'rspec/core/formatters/progress_formatter'
  require 'active_record/connection_adapters/postgresql_adapter'
  require 'erb'
  require 'uri'
  require 'rack'
  require 'capybara/util/timeout'
  require 'selenium/webdriver/firefox/util'
  require 'selenium/webdriver/firefox/extension'
  require 'selenium/webdriver/firefox/socket_lock'
  require 'selenium/webdriver/firefox/binary'
  require 'selenium/webdriver/firefox/profiles_ini'
  require 'selenium/webdriver/firefox/profile'
  require 'selenium/webdriver/firefox/launcher'
  require 'selenium/webdriver/firefox/bridge'
  require 'net/http'
  require 'digest/sha2'
  require 'rake'
end

Spork.each_run do
  Capybara.current_driver = :selenium
  %w(pinaple apple lemon raspberries orange).each do |fruit|
    Product.create(:name => fruit, :available_on => Time.now-12.hours, :description => '', :price => rand(12)+3)
  end
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

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
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
end
