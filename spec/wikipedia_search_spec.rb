require 'acceptance_test'

acceptance_test = AcceptanceTest.new
acceptance_test.configure({webapp_url: "http://www.wikipedia.org", timeout_in_seconds: 10})

RSpec.describe 'Wikipedia Search' do

  before do
    puts "Using driver: #{Capybara.current_driver}."
    puts "Default wait time: #{Capybara.default_wait_time}."
  end

  it "uses selenium driver", driver: :selenium, exclude: false do
    visit('/')

    fill_in "searchInput", :with => "Capybara"

    find(".formBtn", match: :first).click

    expect(page).to have_content "Hydrochoerus hydrochaeris"
  end

  it "uses webkit driver", driver: :webkit do
    visit('/')

    fill_in "searchInput", :with => "Capybara"

    find(".formBtn", match: :first).click

    expect(page).to have_content "Hydrochoerus hydrochaeris"
  end

  it "uses poltergeist driver", driver: :poltergeist do
    visit('/')

    fill_in "searchInput", :with => "Capybara"

    find(".formBtn", match: :first).click

    expect(page).to have_content "Hydrochoerus hydrochaeris"
  end
end