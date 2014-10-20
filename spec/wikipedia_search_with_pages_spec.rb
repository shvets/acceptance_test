require 'acceptance_test'
require 'rspec/expectations'


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

  let(:page_set) { WikipediaPages.new(self) }

  before do
    AcceptanceTest.instance.setup

    puts "Using driver: #{Capybara.current_driver}."
    puts "Default wait time: #{Capybara.default_wait_time}."
  end

  after do
    AcceptanceTest.instance.teardown
  end

  it "searches on wikipedia web site" do
    page_set.execute do
      visit_home_page

      enter_word "Capybara"

      submit_request

      expect(page).to have_content "Hydrochoerus hydrochaeris"
    end
  end
end