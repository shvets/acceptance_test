require 'singleton'
require 'active_support/core_ext/hash'

require 'acceptance_test/gherkin_ext'

class AcceptanceTest
  include Singleton

  attr_reader :config

  def initialize
    require 'capybara'

    Capybara.default_driver = :selenium

    @config = HashWithIndifferentAccess.new

    @config[:browser] = 'firefox'
    @config[:screenshot_dir] = File.expand_path('tmp')
    @config[:timeout_in_seconds] = 20

    init
  end

  def configure hash={}
    config.merge!(HashWithIndifferentAccess.new(hash))
  end

  def setup page=nil, webapp_url=nil
    # driver_name = register_driver(config[:driver], config[:browser])
    #
    # use_driver(driver_name, page)

    Capybara.app_host = webapp_url.nil? ? config[:webapp_url] : webapp_url

    Capybara.configure do |conf|
      conf.default_wait_time = config[:timeout_in_seconds]

      conf.match = :first

      conf.ignore_hidden_elements = false
    end
  end

  def teardown
    Capybara.app_host = nil

    Capybara.configure do |conf|
      conf.default_wait_time = 2
    end

    Capybara.default_driver = :rack_test
  end

  def register_driver(driver, browser=:firefox)
    driver_name = build_driver_name(config[:driver], config[:browser], config[:selenium_url])

    case driver
      when :poltergeist
        require 'capybara/poltergeist'

      when :webkit
        require "capybara-webkit"

      when :firefox_with_firebug
        require 'capybara/firebug'

      else
      ;
    end

    if driver == :poltergeist
      properties = {}
      properties[:debug] = false

      Capybara.register_driver :poltergeist do |app|
        Capybara::Poltergeist::Driver.new(app, properties)
      end
    else
      properties = {}
      properties[:browser] = browser

      # driver_name = "#{driver}_#{browser}".to_sym

      Capybara.register_driver driver_name do |app|
        Capybara::Selenium::Driver.new(app, properties)
      end

      Capybara.register_driver :selenium do |app|
        Capybara::Selenium::Driver.new(app, properties)
      end if driver.nil?
    end

    driver_name
  end

  # profile = Selenium::WebDriver::Firefox::Profile.new
  # profile.enable_firebug
  #
  # properties[:desired_capabilities] = Selenium::WebDriver::Remote::Capabilities.firefox(:firefox_profile => profile)
  #properties[:desired_capabilities] = Selenium::WebDriver::Remote::Capabilities.internet_explorer

  def use_driver driver, page=nil
    if driver and Capybara.drivers[driver]
      Capybara.current_driver = driver
      Capybara.javascript_driver = driver

      page.instance_variable_set(:@mode, driver) if page
    end
  end

  def add_expectations context
    require 'rspec/expectations'

    context.send :include, Capybara::DSL
  end

  def enable_external_source data_reader
    GherkinExt.enable_external_source data_reader
  end

  def configure_turnip report_name
    require 'turnip/rspec'
    require 'turnip/capybara'

    configure_turnip_formatter report_name

    #extend_turnip
  end

  # def extend_turnip
  #   shared_context_name = "#{random_name}AcceptanceTest"
  #
  #   create_shared_context shared_context_name
  #
  #   TurnipExt.shared_context_with_turnip shared_context_name
  # end

  def configure_turnip_formatter report_name
    require 'turnip_formatter'
    require 'gnawrnip'

    RSpec.configure do |config|
      config.add_formatter RSpecTurnipFormatter, report_name
    end

    Gnawrnip.configure do |c|
      c.make_animation = true
      c.max_frame_size = 1024 # pixel
    end

    Gnawrnip.ready!
  end

  def metadata_from_scenario scenario
    tags = scenario.source_tag_names.collect { |a| a.gsub("@", '') }

    metadata = {}

    if tags.size > 0
      tag = tags.first.to_sym

      if driver_manager.supported_drivers.include? tag
        metadata[:driver] = tag
      end
    end

    metadata
  end

  private

  def init
    # try to load capybara-related rspec library
    begin
      require 'capybara/rspec'

      RSpec.configure do |conf|
        conf.filter_run_excluding :exclude => true
      end

      RSpec.configure do |conf|
        conf.include Capybara::DSL
      end

      RSpec::Core::ExampleGroup.send :include, Capybara::DSL
    rescue
      ;
    end
  end

  def build_driver_name driver=nil, browser=nil, selenium_url=nil
    name = ""

    name += driver ? "#{driver}_" : "#{Capybara.default_driver}_"

    name += "#{browser}_" if browser

    name += "remote" if selenium_url

    name = name[0..name.size-2] if name[name.size-1] == "_"

    name = "unsupported" if name.size == 0

    name.to_sym
  end

  # def random_name
  #   ('a'..'z').to_a.shuffle[0, 12].join
  # end
end
