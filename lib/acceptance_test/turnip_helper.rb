require 'turnip/capybara'
require 'turnip/rspec'
require 'csv'
require 'yaml'
require 'acceptance_test'

require 'acceptance_test/gherkin_helper'

class TurnipHelper
  attr_reader :acceptance_test

  def initialize
    @acceptance_test = AcceptanceTest.instance

    RSpec.configure do |config|
      config.include Capybara::DSL
    end

    enable_external_source
  end

  def register_steps path, class_name, tag, shared_group
    require path

    clazz = Object.const_get(class_name)

    RSpec.configure do |config|
      config.include clazz, tag => true
    end

    acceptance_test.create_shared_context shared_group
  end

  private

  def enable_external_source # enable external source for gherkin
    data_reader = lambda {|source_path| CSV.read(File.expand_path(source_path)) }

    GherkinHelper.instance.enable_external_source data_reader
  end
end
