require 'test_helper'

require 'acceptance_test'

acceptance_test = AcceptanceTest.instance
acceptance_test.configure({webapp_url: "http://www.wikipedia.org", timeout_in_seconds: 10})
acceptance_test.configure_rspec

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