require 'acceptance_test'
require 'rspec/expectations'
require 'capybara/rspec'

RSpec::configure do |config|
  config.include Capybara::RSpecMatchers
end

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

AcceptanceTest.instance.configure({webapp_url: 'http://www.wikipedia.org', timeout_in_seconds: 10,
                                   driver: :selenium, browser: :chrome})

require 'test_helper'
require 'pages/wikipedia_pages'

RSpec.describe 'Wikipedia Search' do
  include Capybara::DSL

  let(:pages) { WikipediaPages.new(self) }

  before do |example|
    AcceptanceTest.instance.setup page, example.metadata

    puts "Using driver: #{Capybara.current_driver}."
    puts "Default wait time: #{Capybara.default_wait_time}."
  end

  after do |example|
    AcceptanceTest.instance.teardown page, example.metadata
  end

  it "searches on wikipedia web site" do
    pages.execute do
      visit_home_page

      enter_word "Capybara"

      submit_request

      expect(page).to have_content "Hydrochoerus hydrochaeris"
    end
  end
end