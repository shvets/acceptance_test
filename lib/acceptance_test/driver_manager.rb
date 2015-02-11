require 'capybara'

class DriverManager

  def initialize
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

  def supported_drivers
    [:selenium, :webkit, :poltergeist]
  end

  def supported_browsers
    [:firefox, :chrome]
  end

  def register_driver(driver, browser=:firefox, selenium_url=nil, capabilities=nil)
    driver_name = build_driver_name(driver, browser, selenium_url)

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
    elsif driver == :webkit
      ;
    else
      properties = {}

      if selenium_url
        properties[:browser] = :remote
        properties[:url] = selenium_url

        case browser
          when :firefox
        # profile = Selenium::WebDriver::Firefox::Profile.new
        # profile.enable_firebug
            # capabilities = Selenium::WebDriver::Remote::Capabilities.firefox(:firefox_profile => profile)

            caps = Selenium::WebDriver::Remote::Capabilities.firefox
          when :chrome
            caps = Selenium::WebDriver::Remote::Capabilities.chrome
          else
            ;
        end

        desired_capabilities =
          if caps
            capabilities.each do |key, value|
              caps[key] = value
            end if capabilities

            caps
          elsif capabilities
            capabilities
          end

        properties[:desired_capabilities] = desired_capabilities if desired_capabilities
      else
        properties[:browser] = browser
      end

      Capybara.register_driver driver_name do |app|
        Capybara::Selenium::Driver.new(app, properties)
      end
    end

    driver_name
  end

  def use_driver driver, page=nil
    if driver and Capybara.drivers[driver]
      Capybara.current_driver = driver
      Capybara.javascript_driver = driver

      page.instance_variable_set(:@mode, driver) if page
    end
  end

  def setup_browser_binary driver_name, browser_binaries
    case driver_name
      when :firefox
        Selenium::WebDriver::Firefox::Binary.path = browser_binaries[driver_name]
      when :chrome
        Selenium::WebDriver::Chrome::Service.Service.executable_path = browser_binaries[driver_name]
      else
        ;
    end
  end

  private

  def build_driver_name driver, browser, selenium_url=nil
    case driver
      when :webkit
        :webkit
      when :poltergeist
        :poltergeist
      when :selenium
        name = ""
        name += driver ? "#{driver}_" : "#{Capybara.default_driver}_"

        name += "#{browser}_" if browser
        name += "remote" if selenium_url
        name = name[0..name.size-2] if name[name.size-1] == "_"

        name.to_sym
      else
        :unsupported
      end
  end

end
