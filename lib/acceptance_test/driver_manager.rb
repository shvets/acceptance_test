require 'capybara'
#require "capybara/dsl"

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

  def register_driver tag, browser, selenium_url
    driver_name, properties = *recognize_driver(tag, browser)

    if driver_name
      unless Capybara.drivers[driver_name]
        if driver_name == :poltergeist
          Capybara.register_driver :poltergeist do |app|
            Capybara::Poltergeist::Driver.new(app, { debug: false })
          end
        else
          if driver_name =~ /remote/
            properties[:browser] = :remote
            properties[:url] = selenium_url
            properties[:desired_capabilities] = capabilities if capabilities

            Capybara.register_driver driver_name do |app|
              Capybara::Selenium::Driver.new(app, properties)
            end
          else
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

  private

  def recognize_driver tag, browser
    properties = {}

    driver_name =
        case tag
          when :webkit
            require "capybara-webkit"

            :webkit

          when :selenium

            case browser
              when :firefox
                :selenium_firefox

              when :firefox_with_firebug
                require 'capybara/firebug'

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
            require 'capybara/poltergeist'

            :poltergeist

          when :selenium_remote
            case browser
              when :firefox
                :selenium_remote_firefox

              when :firefox_with_firebug
                require 'capybara/firebug'

                profile = Selenium::WebDriver::Firefox::Profile.new
                profile.enable_firebug

                properties[:desired_capabilities] = Selenium::WebDriver::Remote::Capabilities.firefox(:firefox_profile => profile)

                :selenium_remote_firefox_with_firebug

              when :ie
                properties[:desired_capabilities] = Selenium::WebDriver::Remote::Capabilities.internet_explorer

                :selenium_remote_ie
              else
                :unsupported
            end
          else
            :unsupported
        end

    [driver_name, properties]
  end

end