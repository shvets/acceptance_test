require 'uri'
require 'capybara'

require 'active_support/core_ext/hash'

require 'acceptance_test/acceptance_test_helper'

class AcceptanceTest
  attr_reader :project_root, :config, :screenshot_dir
  attr_accessor :app_host

  def initialize project_root, config, screenshot_dir
    @project_root = File.expand_path(project_root.to_s)
    @screenshot_dir = File.expand_path(screenshot_dir.to_s)

    @app_host = default_app_host

    @config = config.kind_of?(HashWithIndifferentAccess) ? config : HashWithIndifferentAccess.new(config)

    configure
  end

  def before metadata={}
    driver = driver(metadata)

    if driver
      register_driver driver

      select_driver driver
    end

    # puts "Current Driver    : #{Capybara.current_driver}"

    setup_app_host app_host
  end

  def after metadata={}, exception=nil, page=nil
      driver = driver(metadata)

    if driver and exception and page and not [:webkit].include? driver
      screenshot_maker = ScreenshotMaker.new screenshot_dir

      screenshot_maker.make page, metadata

      puts metadata[:full_description]
      puts "Screenshot: #{screenshot_maker.screenshot_url(metadata)}"
    end

    Capybara.current_driver = Capybara.default_driver
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

  def default_app_host
    "http://#{AcceptanceTestHelper.instance.get_localhost}:3000"
  end

  def configure
    run_server = (ENV['RUN_SERVER'] == "true")

    if run_server and defined? Rails
      require 'rspec/rails'
      require "capybara/rails"
    end

    require "capybara"
    require "capybara/dsl"

    # try to load capybara-related rspec library
    begin
      require 'capybara/rspec'
    rescue
      ;
    end

    if defined? RSpec
      RSpec.configure do |config|
        config.filter_run_excluding :exclude => true
      end

      RSpec.configure do |config|
        config.include Capybara::DSL
      end

      RSpec::Core::ExampleGroup.send :include, Capybara::DSL
    end

    Capybara.configure do |config|
      config.default_wait_time = timeout_in_seconds

      config.run_server = run_server
    end

    ENV['APP_HOST'] ||= app_host
    ENV['WAIT_TIME'] ||= Capybara.default_wait_time.to_s
  end

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
        setup_driver_from_config driver
      else
        if acceptance_config_exist?
          setup_driver_from_config driver
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

  def setup_app_host app_host
    Capybara.app_host = app_host
    Capybara.server_port = URI.parse(app_host).port
  end

  def app_host_from_url url
    uri = URI(url)

    "#{uri.scheme}://#{uri.host}:#{uri.port}"
  end

  def acceptance_config_exist?
    not config.nil?
  end

  def setup_driver_from_config driver
    @app_host = app_host_from_url(config[:webapp_url])

    # Rails.env = config[:env] if defined? Rails.env

    Capybara.current_driver = driver
    Capybara.javascript_driver = driver
  end

end
