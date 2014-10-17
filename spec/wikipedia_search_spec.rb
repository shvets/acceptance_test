require 'acceptance_test'

AcceptanceTest.instance.configure({webapp_url: 'http://www.wikipedia.org', timeout_in_seconds: 10})

AcceptanceTest.instance.register_driver(:selenium, :chrome)
AcceptanceTest.instance.register_driver(:webkit)
AcceptanceTest.instance.register_driver(:poltergeist)

RSpec.describe 'Wikipedia Search' do
  AcceptanceTest.instance.add_expectations(self)

  before do
    AcceptanceTest.instance.setup

    puts "Using driver: #{Capybara.current_driver}."
    puts "Default wait time: #{Capybara.default_wait_time}."
  end

  after do
    AcceptanceTest.instance.teardown
  end

  it "uses selenium driver" do
    AcceptanceTest.instance.use_driver(:selenium_chrome, page)

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