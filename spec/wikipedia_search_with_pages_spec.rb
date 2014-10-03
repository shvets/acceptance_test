require 'acceptance_test'

acceptance_test = AcceptanceTest.new
acceptance_test.configure({webapp_url: "http://www.wikipedia.org", timeout_in_seconds: 10})

$: << File.expand_path('spec/support')

require 'wikipedia/wikipedia_page_set'

RSpec.describe 'Wikipedia Search' do

  let(:page_set) { WikipediaPageSet.new(page) }

  before do
    puts "Using driver: #{Capybara.current_driver}."
    puts "Default wait time: #{Capybara.default_wait_time}."
  end

  it "searches on wikipedia web site", driver: :selenium do
    page_set.execute do
      visit_page "/"

      enter_search_request "Capybara"

      click_search_button

      expect(page).to have_content "Hydrochoerus hydrochaeris"
    end
  end
end