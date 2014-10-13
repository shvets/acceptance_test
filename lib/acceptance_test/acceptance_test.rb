require 'uri'
require 'singleton'

require 'active_support/core_ext/hash'

require 'acceptance_test/driver_manager'
require 'acceptance_test/gherkin_ext'
require 'acceptance_test/turnip_ext'

class AcceptanceTest
  include Singleton

  attr_reader :config, :driver_manager

  def initialize
    @driver_manager = DriverManager.new
  end

  def configure config={}
    if config
      @config = config.kind_of?(HashWithIndifferentAccess) ? config : HashWithIndifferentAccess.new(config)
    else
      @config = HashWithIndifferentAccess.new
    end

    @config[:browser] = 'firefox' unless @config[:browser]
    @config[:screenshot_dir] = File.expand_path('tmp') unless @config[:screenshot_dir]
  end

  def setup
    Capybara.app_host = AcceptanceTest.instance.config[:webapp_url]

    Capybara.configure do |conf|
      conf.default_wait_time = timeout_in_seconds
    end

    ENV['WAIT_TIME'] ||= Capybara.default_wait_time.to_s

    Capybara.default_driver = :selenium
  end

  def teardown
    Capybara.app_host = nil

    Capybara.configure do |conf|
      conf.default_wait_time = 5
    end

    Capybara.default_driver = :rack_test
  end

  def before_test metadata={}, page=nil
    setup unless Capybara.app_host

    tag = driver(metadata)

    if tag
      driver_name = driver_manager.register_driver tag, config[:browser].to_sym, config[:selenium_url]

      if driver_name and Capybara.drivers[driver_name]
        Capybara.current_driver = driver_name
        Capybara.javascript_driver = driver_name

        page.instance_variable_set(:@mode, driver_name) if page
      end
    end
  end

  def after_test metadata={}, exception=nil, page=nil
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
    Capybara.javascript_driver = Capybara.default_driver
  end

  def create_shared_context name
    throw "rspec library is not available" unless defined? RSpec

    acceptance_test = self

    acceptance_test_lambda = lambda do
      acceptance_test.configure_rspec self
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

      if driver_manager.supported_drivers.include? tag
        metadata[:driver] = tag
      end
    end

    metadata
  end

  def extend_turnip
    shared_context_name = "#{random_name}AcceptanceTest"

    create_shared_context shared_context_name

    TurnipExt.shared_context_with_turnip shared_context_name
  end

  def enable_external_source data_reader
    GherkinExt.enable_external_source data_reader
  end

  def driver metadata
    driver = ENV['DRIVER'].nil? ? nil : ENV['DRIVER'].to_sym

    driver = metadata[:driver] if driver.nil?

    driver_manager.supported_drivers.each do |supported_driver|
      driver = supported_driver if metadata[supported_driver]
      break if driver
    end

    driver = :webkit if driver.nil?

    driver
  end

  # def selenium_driver? driver
  #   driver.to_s =~ /selenium/
  # end

  def configure_rspec object=nil
    acceptance_test = self

    if object
      if object.kind_of? RSpec::Core::Example
        rspec_conf = object.example_group.parent_groups.last
      else
        rspec_conf = object
      end
    else
      rspec_conf = RSpec.configuration
    end

    rspec_conf.around(:each) do |example|
      acceptance_test.before_test(example.metadata, page)

      example.run

      acceptance_test.after_test(example.metadata, example.exception, page)
    end
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

  def random_name
    ('a'..'z').to_a.shuffle[0, 12].join
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

  # ip = `ifconfig | grep 'inet ' | grep -v 127.0.0.1 | cut -d ' ' -f2`.strip
  # Capybara.app_host = http://#{ip}:#{Capybara.server_port}
end
