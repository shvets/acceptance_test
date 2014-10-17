require 'rspec'
require 'rspec/example_steps'
require "capybara-webkit"

RSpec.configure do |config|
  config.include Capybara::DSL
end

RSpec.describe "Searching" do
  before do
    Capybara.app_host = "http://www.wikipedia.org"
    Capybara.default_driver = :selenium
  end

  Steps "Result found" do
    Given "I am on wikipedia.com" do
      visit('/')
    end

    When "I enter \"Capybara\"" do
      fill_in "searchInput", :with => "Capybara"
    end

    When "I click submit button" do
      find(".formBtn", match: :first).click
    end

    Then "I should see results" do
      expect(page).to have_content "Hydrochoerus hydrochaeris"
    end
  end
end

