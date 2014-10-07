require 'singleton'
require 'turnip/capybara'
require 'turnip/rspec'

require 'acceptance_test'
require 'acceptance_test/gherkin_helper'

class AcceptanceTestHelper
  include Singleton

  def initialize
    RSpec.configure do |config|
      config.include Capybara::DSL
    end
  end

  def configure config
    AcceptanceTest.instance.configure config
  end

  def enable_external_source data_reader
    GherkinHelper.instance.enable_external_source data_reader
  end

  def register_turnip_steps path, class_name, tag, shared_group
    require path

    RSpec.configure do |config|
      config.include class_name.constantize, tag => true
    end

    AcceptanceTest.instance.create_shared_context shared_group
  end

end
