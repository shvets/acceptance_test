require 'yaml'
require 'csv'
require 'active_support/core_ext/hash'

require 'acceptance_test/acceptance_test_helper'

helper = AcceptanceTestHelper.instance

data_reader = lambda {|source_path| CSV.read(File.expand_path(source_path)) }
helper.enable_external_source data_reader # enable external source for gherkin

helper.register_turnip_steps 'features/steps/wikipedia_steps',
                             'WikipediaSteps', :wikipedia, "WikipediaAcceptanceTest"

config_name = File.expand_path("spec/acceptance_config.yml")
config = HashWithIndifferentAccess.new(YAML.load_file(config_name))

helper.configure config

