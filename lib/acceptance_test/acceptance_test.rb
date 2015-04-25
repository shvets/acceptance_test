require 'singleton'
require 'capybara'
require 'active_support/core_ext/hash'

require 'acceptance_test/shared_context_builder'
require 'acceptance_test/driver_manager'
require 'acceptance_test/gherkin_ext'
require 'acceptance_test/turnip_ext'

class AcceptanceTest
  include Singleton

  attr_reader :config, :screenshot_maker, :driver_manager

  def initialize
    Capybara.default_driver = :selenium

    @config = HashWithIndifferentAccess.new

    @config[:browser] = ENV['BROWSER'] || 'firefox'
    @config[:screenshots_dir] = File.expand_path('tmp')
    @config[:timeout_in_seconds] = ENV['TIMEOUT_IN_SECONDS'] || 20

    @screenshot_maker = ScreenshotMaker.new config[:screenshots_dir]

    @driver_manager = DriverManager.new
  end

  def configure hash={}
    config.merge!(HashWithIndifferentAccess.new(hash))
  end

  def setup page=nil, metadata={}
    driver = driver(metadata)
    browser = browser(metadata)

    driver_name = driver_manager.register_driver(driver, browser, config[:selenium_url], config[:capabilities])

    driver_manager.use_driver(driver_name, page)

    driver_manager.setup_browser_binary config[:browser].to_sym, config[:browser_binaries]

    Capybara.app_host = config[:webapp_url]

    Capybara.configure do |conf|
      conf.default_wait_time = config[:timeout_in_seconds]

      conf.match = :first

      conf.ignore_hidden_elements = false
    end
  end

  def teardown page=nil, metadata={}, exception=nil
    driver = driver(metadata)

    if driver and exception and page and not [:webkit].include? driver
      screenshot_maker.basedir = File.expand_path(config[:screenshots_dir])

      screenshot_maker.make page, metadata

      puts metadata[:full_description]
      puts "Screenshot: #{screenshot_maker.screenshot_url(metadata)}"
    end

    Capybara.app_host = nil

    Capybara.configure do |conf|
      conf.default_wait_time = 2
    end

    Capybara.current_driver = Capybara.default_driver
    Capybara.javascript_driver = Capybara.default_driver
  end

  def create_shared_context name
    SharedContextBuilder.instance.build name, self
  end

  def extend_turnip
    shared_context_name = "#{random_name}AcceptanceTest"

    SharedContextBuilder.instance.build shared_context_name, self

    TurnipExt.shared_context_with_turnip shared_context_name
  end

  def enable_external_source data_reader
    GherkinExt.enable_external_source data_reader
  end

  def configure_turnip report_file, title
    # configure turnip formatter

    require 'turnip_formatter'

    RSpec.configure do |config|
      config.add_formatter RSpecTurnipFormatter, report_file
    end

    TurnipFormatter.configure do |config|
      config.title = title
    end

    # configure gnawrnip

    Gnawrnip.configure do |c|
      c.make_animation = true
      c.max_frame_size = 1024 # pixel
    end

    Gnawrnip.ready!
  end

  def ignore_case_in_steps
    require 'turnip/builder'

    Turnip::Builder::Step.class_eval do
      def initialize *params
        description = params[0]
        new_description = ""

        words = description.split(/\s/)

        first_word = words.first

        if ["I", "(I)"].include?(first_word)
          new_description += first_word
        else
          new_description += first_word.downcase
        end

        words.delete first_word

        words.each do |word|
          new_description += " "

          if word =~ /a..z|A..z|0..9/
            new_description += word.downcase
          else
            new_description += word
          end
        end

        params[0] = new_description

        super
      end
    end
  end

  private

  def driver metadata
    driver = ENV['DRIVER'].nil? ? nil : ENV['DRIVER'].to_sym

    driver = config[:driver].to_sym if driver.nil? and config[:driver]

    driver = metadata[:driver] if driver.nil?

    driver_manager.supported_drivers.each do |supported_driver|
      driver = supported_driver if metadata[supported_driver]
      break if driver
    end if driver.nil?

    driver = :webkit if driver.nil?

    driver
  end

  def browser metadata
    browser = ENV['BROWSER'].nil? ? nil : ENV['BROWSER'].to_sym

    browser = config[:browser].to_sym if browser.nil?

    browser = metadata[:browser] if browser.nil?

    driver_manager.supported_browsers.each do |supported_browser|
      browser = supported_browser if metadata[supported_browser]
      break if browser
    end if browser.nil?

    browser = :firefox if browser.nil?

    browser
  end

  def random_name
    ('a'..'z').to_a.shuffle[0, 12].join
  end

end
