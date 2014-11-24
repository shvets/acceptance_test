require 'yaml'
require 'csv'
require 'active_support/core_ext/hash'

require 'test_helper'

require 'acceptance_test'

require 'turnip/capybara'
require 'gnawrnip'

require 'steps/search_with_drivers_steps'
require 'steps/search_with_pages_steps'
require 'steps/search_with_scenario_outline_steps'
require 'steps/search_with_table_steps'

acceptance_test = AcceptanceTest.instance

RSpec.configure do |conf|
  conf.before(:type => :feature) do
    config_name = File.expand_path("spec/acceptance_config.yml")
    config = config_name ? HashWithIndifferentAccess.new(YAML.load_file(config_name)) : {}

    acceptance_test.configure(config)

    # acceptance_test.configure(webapp_url: 'http://www.wikipedia.org')
    # acceptance_test.register_driver(:webkit)
    # acceptance_test.register_driver(:poltergeist)

    acceptance_test.configure_turnip 'tmp/report.html', "test"

    acceptance_test.setup
  end

  conf.after(:type => :feature) do
    acceptance_test.teardown
  end
end





