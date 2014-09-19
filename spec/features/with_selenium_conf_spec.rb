require 'acceptance_test'
require 'yaml'

RSpec.describe 'Google Search' do
  include_context "AcceptanceTest"

  before :all do
    #acceptance_config_file = "spec/features/acceptance_config.yml"

    # acceptance_test.acceptance_config = YAML.load_file(acceptance_config_file)
    #
    # acceptance_config = acceptance_test.acceptance_config

    # env = acceptance_config[:env]
    #
    # puts "\nEnvironment: #{@acceptance_config[:env]}" if env
    # puts "Application: #{@acceptance_config[:webapp_url]}"
    #
    # driver = acceptance_test.driver(metadata)
    #
    # if acceptance_test.selenium_driver?(driver)
    #   selenium_host = acceptance_config[:selenium_host]
    #   selenium_port = acceptance_config[:selenium_port]
    #
    #   puts "Selenium: #{selenium_host}:#{selenium_port}"
    # end
  end

  before do
    # puts "Using driver: #{Capybara.current_driver}."
    # puts "Default wait time: #{Capybara.default_wait_time}."
  end

  it "uses selenium driver", driver: :selenium_remote do
    visit('/')

    fill_in "q", :with => "Capybara"

    find("#gbqfbw button").click

    all(:xpath, "//li[@class='g']/h3/a").each { |a| puts a[:href] }
  end
end