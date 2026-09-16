# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort('RSpec must run in the test environment') unless Rails.env.test?
require 'rspec/rails'

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.fixture_paths = [Rails.root.join('test/fixtures')]
  config.global_fixtures = :all
  config.use_transactional_fixtures = true
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.fail_if_no_examples = true
  config.order = :random
  config.filter_rails_from_backtrace!
end
