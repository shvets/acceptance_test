require 'acceptance_test'

config_name = File.expand_path("spec/features/acceptance_config.yml")

helper = AcceptanceTestHelper.instance

acceptance_test = helper.create_acceptance_test ".", config_name, "tmp"

helper.create_shared_context acceptance_test, "GoogleAcceptanceTest"
