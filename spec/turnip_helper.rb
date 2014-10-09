require 'yaml'
require 'csv'
require 'active_support/core_ext/hash'

require 'acceptance_test/acceptance_test_helper'

helper = AcceptanceTestHelper.instance

data_reader = lambda {|source_path| CSV.read(File.expand_path(source_path)) }
helper.enable_external_source data_reader # enable external source for gherkin

helper.register_turnip_steps 'features/steps/search_with_drivers_steps',
                             'SearchWithDriversSteps', :search_with_drivers, "SearchWithDriversAcceptanceTest"
helper.register_turnip_steps 'features/steps/search_with_examples_from_csv_steps',
                             'SearchWithExamplesFromCsvSteps', :search_with_examples_from_csv, "SearchWithExamplesFromCsvAcceptanceTest"
helper.register_turnip_steps 'features/steps/search_with_table_steps',
                             'SearchWithTableSteps', :search_with_table, "SearchWithTableAcceptanceTest"

config_name = File.expand_path("spec/acceptance_config.yml")
config = HashWithIndifferentAccess.new(YAML.load_file(config_name))

helper.configure config

