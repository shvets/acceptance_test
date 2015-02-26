require 'acceptance_test/acceptance_config'

ENV['CONFIG_FILE'] = "spec/wikipedia/acceptance_config.yml"
ENV['DATA_DIR'] = "spec/wikipedia/acceptance_data"

AcceptanceConfig.instance.configure "spec", "wikipedia"

RSpec.configure do |c|
#      c.add_formatter 'progress'
  c.add_formatter 'documentation'
end
