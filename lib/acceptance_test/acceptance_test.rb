require 'uri'
require 'capybara'

require 'yaml'
require 'active_support/hash_with_indifferent_access'

class AcceptanceTest
  attr_accessor :app_host

  def initialize project_root="."
    @project_root = project_root

    #@app_host = default_app_host

    set_defaults

    configure
  end

  def before context
    driver = driver(context)

    if driver
      register_driver driver

      select_driver driver

      if driver.to_s =~ /selenium/ and selenium_config_exist?
        puts "\nSelenium Configuration: #{@selenium_config[:name]}"
        puts "Environment: #{@selenium_config[:env]}"
        puts "Application: #{@selenium_config[:webapp_url]}"
        puts "Selenium: #{@selenium_config[:selenium_host]}:#{@selenium_config[:selenium_port]}"
      end
    end

    setup_app_host app_host
  end

  def after context
    context.reset_session!

    if context.example.exception
      driver = driver(context)

      if driver and not [:webkit].include? driver
        save_screenshot context.example, context.page
      end
    end

    Capybara.current_driver = Capybara.default_driver
  end

  def load_selenium_config file_name, config_name
    @selenium_config = HashWithIndifferentAccess.new YAML.load_file(file_name)[config_name]

    @selenium_config[:name] = config_name
  end

  private

  def default_app_host
    "http://#{AcceptanceTestHelper.get_localhost}:3000"
  end

  def set_defaults
    ENV['APP_HOST'] ||= app_host
    ENV['WAIT_TIME'] ||= "60"
  end

  def configure
    run_server = (ENV['RUN_SERVER'] == "true")

    if run_server and defined? Rails
      require 'rspec/rails'
      require "capybara/rails"
    end

    #require 'rspec/autorun'

    require "capybara"
    require "capybara/dsl"
    require 'capybara/rspec'

    RSpec.configure do |config|
      config.filter_run_excluding :exclude => true
    end

    RSpec.configure do |config|
      config.include Capybara::DSL
    end

    RSpec::Core::ExampleGroup.send :include, Capybara::DSL

    Capybara.configure do |config|
      config.default_wait_time = ENV['WAIT_TIME'].to_i
      config.run_server = run_server

      #config.always_include_port = false
      #config.server {|app, port| Capybara.run_default_server(app, port)}
      #config.default_selector = :css
      #config.ignore_hidden_elements = false
      #config.default_host = "http://www.example.com"
      #config.automatic_reload = true
    end

    #Capybara.configure do |config|
    #  config.match = :one
    #  config.exact_options = true
    #  config.ignore_hidden_elements = true
    #  config.visible_text_only = true
    #end
    #
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
          selenium_url = "http://#{@selenium_config[:selenium_host]}:#{@selenium_config[:selenium_port]}/wd/hub"

          Capybara.register_driver :selenium_remote do |app|
            Capybara::Selenium::Driver.new(app, {:browser => :remote, :url => selenium_url})

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
    if [:js, :javascript].include? driver
      Capybara.current_driver = Capybara.javascript_driver
    elsif [:webkit, :poltergeist].include? driver
      Capybara.current_driver = driver
      Capybara.javascript_driver = driver
    elsif [:selenium, :selenium, :selenium_with_firebug, :selenium_chrome].include? driver
      if selenium_config_exist?
        setup_driver_from_config driver
      else
        Capybara.current_driver = driver
        Capybara.javascript_driver = driver
      end

    elsif [:selenium_remote].include? driver
      setup_driver_from_config driver
    else
      Capybara.current_driver = Capybara.default_driver
    end
  end

  def driver context
    driver = ENV['DRIVER'].nil? ? nil : ENV['DRIVER'].to_sym

    driver = context.example.metadata[:driver] if driver.nil?

    driver = :webkit if driver.nil?

    driver
  end

  def setup_app_host app_host
    Capybara.app_host = app_host
    Capybara.server_port = URI.parse(app_host).port
  end

  def app_host_from_url url
    uri = URI(url)

    "#{uri.scheme}://#{uri.host}:#{uri.port}"
  end

  def save_screenshot example, page
    file_path = example.metadata[:file_path]
    line_number = example.metadata[:line_number]
    full_description = example.metadata[:full_description]

    filename = File.basename(file_path)

    screenshot_name = "screenshot-#{filename}-#{line_number}.png"
    screenshot_path = "#{@project_root.join("tmp")}/#{screenshot_name}"

    page.save_screenshot(screenshot_path)

    project_url = ENV['BUILD_URL'].nil? ? "file:///#{@project_root}" : "#{ENV['BUILD_URL']}../ws"

    screenshot_url = "#{project_url}/tmp/#{screenshot_name}"

    puts full_description + "\n Screenshot: #{screenshot_url}"
  end

  def selenium_config_exist?
    not @selenium_config.nil? and @selenium_config.size > 0
  end

  def setup_driver_from_config driver
    selenium_app_host = app_host_from_url(@selenium_config[:webapp_url])
    #setup_app_host selenium_app_host
    @app_host = selenium_app_host

    Rails.env = @selenium_config[:env] if defined? Rails.env

    Capybara.current_driver = driver
    Capybara.javascript_driver = driver
  end
end

