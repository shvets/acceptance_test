require 'acceptance_test/turnip_helper'

helper = TurnipHelper.new

config_name = File.expand_path("spec/acceptance_config.yml")
config = HashWithIndifferentAccess.new(YAML.load_file(config_name))

helper.acceptance_test.configure config

helper.register_steps 'features/steps/wikipedia_steps', 'WikipediaSteps', :wikipedia, "WikipediaAcceptanceTest"


