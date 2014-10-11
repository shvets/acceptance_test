require 'yaml'
require 'csv'
require 'active_support/core_ext/hash'

require 'acceptance_test'

require 'test_helper'

acceptance_test = AcceptanceTest.instance

# enable external source for gherkin

data_reader = lambda {|source_path| CSV.read(File.expand_path(source_path)) }

acceptance_test.enable_external_source data_reader

acceptance_test.extend_turnip

require  'steps/search_with_drivers_steps'
require  'steps/search_with_page_steps'
require  'steps/search_with_examples_from_csv_steps'
require  'steps/search_with_table_steps'

config_name = File.expand_path("spec/acceptance_config.yml")
config = HashWithIndifferentAccess.new(YAML.load_file(config_name))

acceptance_test.configure config
acceptance_test.configure_rspec

