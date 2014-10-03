require 'turnip/capybara'
require 'turnip/rspec'

RSpec.configure do |config|
  config.include Capybara::DSL
end

require 'features/steps/wikipedia_steps'

RSpec.configure do |config|
  config.include WikipediaSteps, :wikipedia => true
end

require 'acceptance_test/gherkin_helper'

# enable external source for gherkin

data_reader = lambda {|source_path| CSV.read(File.expand_path(source_path)) }
GherkinHelper.instance.enable_external_source data_reader

