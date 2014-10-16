require 'test_helper'

require 'acceptance_test'

# acceptance_test = AcceptanceTest.instance
# acceptance_test.configure({webapp_url: "http://www.wikipedia.org", timeout_in_seconds: 10})
# acceptance_test.configure_rspec

# require "capybara"
# require 'selenium/webdriver'
#
# RSpec.configure do |config|
#   config.include Capybara::DSL
# end
#
# profile = Selenium::WebDriver::Chrome::Profile.new
# # profile['download.prompt_for_download'] = false
# profile['webdriver.chrome.driver'] = "c:\\work\\selenium-server\\chromedriver.exe"
#
# # properties[:profile] = profile
#
# properties = {}
# properties[:url] = "http://10.111.74.226:4444/wd/hub"
# properties[:browser] = :remote
# properties[:desired_capabilities] = Selenium::WebDriver::Remote::Capabilities.chrome(:profile => profile)
#
#
# # ENV['webdriver.chrome.driver'] = "c:\work\selenium-server\chromedriver.exe"
# #properties[:desired_capabilities]['webdriver.chrome.driver'] = "c:\work\selenium-server\chromedriver.exe"
#
# Capybara.register_driver :selenium_remote do |app|
#   Capybara::Selenium::Driver.new(app, properties)
# end
#
# Capybara.app_host = "http://www.wikipedia.org"
# Capybara.default_driver = :selenium_remote


require 'pages/wikipedia_pages'

RSpec.describe 'Wikipedia Search' do

  let(:page_set) { WikipediaPages.new(page) }

  before do
    puts "Using driver: #{Capybara.current_driver}."
    puts "Default wait time: #{Capybara.default_wait_time}."
  end

  it "searches on wikipedia web site", driver: :selenium do
    page_set.execute do
      visit_home_page

      enter_word "Capybara"

      submit_request

      expect(page).to have_content "Hydrochoerus hydrochaeris"
    end
  end
end