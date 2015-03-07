require 'acceptance_test/acceptance_config'

ENV['CONFIG_DIR'] = "spec/wikipedia"
ENV['DATA_DIR'] = "spec/wikipedia/acceptance_data"

AcceptanceConfig.instance.configure "spec", app_name: "wikipedia",
                                    enable_external_source: true,
                                    ignore_case_in_steps: true

RSpec.configure do |c|
  # c.add_formatter 'progress'
  c.add_formatter 'documentation'
end
