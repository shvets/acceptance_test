require 'capybara'

class DriverManager

  def initialize
    Capybara.configure do |conf|
      #conf.default_wait_time = timeout_in_seconds
      conf.match = :first

      conf.ignore_hidden_elements = false
    end

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
    [:selenium, :selenium_remote, :webkit, :poltergeist]
  end

  def register_driver driver, browser, selenium_url=nil
    driver_name = assign_driver_name(driver, browser)

    if driver_name
      unless Capybara.drivers[driver_name]
        if selenium_url # remote
          properties = {}

          properties[:browser] = :remote
          properties[:url] = selenium_url
          #properties[:desired_capabilities] = capabilities if capabilities

          driver_name = "#{driver_name}_remote".to_sym

          Capybara.register_driver driver_name do |app|
            Capybara::Selenium::Driver.new(app, properties)
          end
        else
          case driver_name
            when :poltergeist
              require 'capybara/poltergeist'

              Capybara.register_driver :poltergeist do |app|
                Capybara::Poltergeist::Driver.new(app, { debug: false })
              end

            when :webkit
              require "capybara-webkit"

            when :firefox_with_firebug
              require 'capybara/firebug'

              # profile = Selenium::WebDriver::Firefox::Profile.new
              # profile.enable_firebug
              #
              # properties[:desired_capabilities] = Selenium::WebDriver::Remote::Capabilities.firefox(:firefox_profile => profile)
              #properties[:desired_capabilities] = Selenium::WebDriver::Remote::Capabilities.internet_explorer

            else
              properties = {}
              properties[:browser] = browser

              Capybara.register_driver driver_name do |app|
                Capybara::Selenium::Driver.new(app, properties)
              end
          end
        end
      end
    end

    driver_name
  end

  def assign_driver_name driver, browser
    case driver
      when :webkit
        :webkit

      when :selenium

        case browser
          when :firefox
            :selenium_firefox

          when :firefox_with_firebug
            :selenium_firefox_with_firebug

          when :chrome
            :selenium_chrome

          when :safari
            :selenium_safari

          when :ie, :internet_explorer
            :selenium_ie

          else
            :unsupported
        end

      when :poltergeist
        :poltergeist

      when :selenium_remote
        case browser
          when :firefox
            :selenium_remote_firefox

          when :firefox_with_firebug
            :selenium_remote_firefox_with_firebug

          when :ie
            :selenium_remote_ie

          else
            :unsupported
        end
      else
        :unsupported
    end
  end

end