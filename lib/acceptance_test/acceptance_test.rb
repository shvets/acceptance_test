require 'uri'
require 'fileutils'

require 'capybara'
require "capybara/dsl"
require 'active_support/core_ext/hash'

class AcceptanceTest
  attr_reader :config

  def initialize config={}
    if config
      @config = config.kind_of?(HashWithIndifferentAccess) ? config : HashWithIndifferentAccess.new(config)
    else
      @config = HashWithIndifferentAccess.new

      config[:screenshot_dir] = File.expand_path('tmp')
    end

    Capybara.configure do |conf|
      conf.default_wait_time = timeout_in_seconds
      conf.match = :first

      conf.ignore_hidden_elements = false
    end

    ENV['APP_HOST'] ||= config[:webapp_url]
    ENV['WAIT_TIME'] ||= Capybara.default_wait_time.to_s

    # try to load capybara-related rspec library
    begin
      require 'capybara/rspec'

      RSpec.configure do |config|
        config.filter_run_excluding :exclude => true
      end

      RSpec.configure do |config|
        config.include Capybara::DSL
      end

      RSpec::Core::ExampleGroup.send :include, Capybara::DSL
    rescue
      ;
    end
  end

  def before metadata={}
    driver = driver(metadata)

    if driver
      register_driver driver

      select_driver driver
    end

    Capybara.app_host = config[:webapp_url]
  end

  def after metadata={}, exception=nil, page=nil
      driver = driver(metadata)

    if driver and exception and page and not [:webkit].include? driver
      screenshot_dir = File.expand_path(config[:screenshot_dir])

      FileUtils.mkdir_p screenshot_dir

      screenshot_maker = ScreenshotMaker.new screenshot_dir

      screenshot_maker.make page, metadata

      puts metadata[:full_description]
      puts "Screenshot: #{screenshot_maker.screenshot_url(metadata)}"
    end

    Capybara.current_driver = Capybara.default_driver
  end

  def create_shared_context name
    throw "rspec library is not available" unless defined? RSpec

    acceptance_test = self

    acceptance_test_lambda = lambda do
      attr_reader :acceptance_test

      before :all do
        @acceptance_test = acceptance_test
      end

      around do |example|
        acceptance_test.before example.metadata

        example.run

        acceptance_test.after example.metadata, example.exception, page

        self.reset_session!
      end
    end

    RSpec.shared_context name do
      self.define_singleton_method(:include_context, acceptance_test_lambda)

      include_context
    end
  end

  def metadata_from_scenario scenario
    tags = scenario.source_tag_names.collect { |a| a.gsub("@", '') }

    metadata = {}

    if tags.size > 0
      tag = tags.first.to_sym

      if AcceptanceTest.supported_drivers.include? tag
        metadata[:driver] = tag
      end
    end

    metadata
  end

  def driver metadata
    driver = ENV['DRIVER'].nil? ? nil : ENV['DRIVER'].to_sym

    driver = metadata[:driver] if driver.nil?

    driver = :webkit if driver.nil?

    driver
  end

  def selenium_driver? driver
    driver.to_s =~ /selenium/
  end

  def self.supported_drivers
    [:webkit, :selenium, :poltergeist, :selenium_remote]
  end

  private

  def timeout_in_seconds
    if ENV['WAIT_TIME']
      ENV['WAIT_TIME'].to_i
    else
      if config[:timeout_in_seconds]
        config[:timeout_in_seconds]
      else
        Capybara.default_wait_time.to_s
      end
    end
  end

  def register_driver driver
    case driver
      when :webkit
        require "capybara-webkit"

      when :selenium
        # nothing

      when :selenium_with_firebug
        require 'capybara/firebug'

      #Capybara.register_driver :selenium_with_firebug do |app|
      #  profile = Selenium::WebDriver::Firefox::Profile.new
      #  profile.enable_firebug
      #  Capybara::Selenium::Driver.new(app, :browser => :firefox, :profile => profile)
      #end

      #Selenium::WebDriver::Firefox::Profile.firebug_version = '1.11.2'
      when :selenium_chrome
        unless Capybara.drivers[:selenium_chrome]
          Capybara.register_driver :selenium_chrome do |app|
            Capybara::Selenium::Driver.new(app, :browser => :chrome)
          end
        end

      when :poltergeist
        require 'capybara/poltergeist'

        unless Capybara.drivers[:poltergeist]
          Capybara.register_driver :poltergeist do |app|
            Capybara::Poltergeist::Driver.new(app, { debug: false })
          end
        end

      when :selenium_remote
        unless Capybara.drivers[:selenium_remote]
          Capybara.register_driver :selenium_remote do |app|
            Capybara::Selenium::Driver.new(app, {:browser => :remote, :url => config[:selenium_url]})

            #profile = Selenium::WebDriver::Firefox::Profile.new
            #profile.enable_firebug
            #
            #Capybara::Driver::Selenium.new(app, {
            #  :browser => :remote,
            #  :url => selenium_url,
            #  :desired_capabilities => Selenium::WebDriver::Remote::Capabilities.firefox(:firefox_profile => profile)
            #})
          end
        end
      when :selenium_safari
        unless Capybara.drivers[:selenium_safari]
          Capybara.register_driver :selenium_safari do |app|
            Capybara::Selenium::Driver.new(app, :browser => :safari)
          end
        end
      else
        # nothing
    end
  end

  def select_driver driver
    if selenium_driver?(driver)
      if driver == :selenium_remote
        Capybara.current_driver = driver
        Capybara.javascript_driver = driver
      else
        if acceptance_config_exist?
          Capybara.current_driver = driver
          Capybara.javascript_driver = driver
        else
          if Capybara.drivers[driver]
            Capybara.current_driver = driver
            Capybara.javascript_driver = driver
          end
        end
      end
    else
      if Capybara.drivers[driver]
        Capybara.current_driver = driver
        Capybara.javascript_driver = driver
      end
    end
  end

  def acceptance_config_exist?
    not config.nil?
  end

  # def self.get_localhost
  #   orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily
  #
  #   UDPSocket.open do |s|
  #     s.connect '192.168.1.1', 1
  #     s.addr.last
  #   end
  # ensure
  #   Socket.do_not_reverse_lookup = orig
  # end
end
