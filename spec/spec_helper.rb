$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

# Don't check coverage in rubinius or ci
unless RUBY_ENGINE == 'rbx' || ENV['TRAVIS'] || ENV['CI']
  require 'english'
  require 'simplecov'

  SimpleCov.start do
    add_filter "spec/support"
  end
end

require 'copy_method'

Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.example_status_persistence_file_path = "spec/examples.txt"

  config.warnings = true

  # config.profile_examples = 10

  config.order = :random
end
