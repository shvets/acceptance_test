require 'turnip/capybara'
require 'turnip/rspec'

require 'features/steps/wikipedia_steps'

RSpec.configure do |config|
  config.include Capybara::DSL
end

RSpec.configure do |config|
  config.include WikipediaSteps
end
