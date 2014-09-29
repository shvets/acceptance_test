# ENV["RAILS_ENV"] ||= 'test'
# puts "Environment: #{ENV["RAILS_ENV"]}"
#
require 'rspec'
require 'rspec/example_steps'
require "capybara-webkit"

RSpec.configure do |config|
  config.include Capybara::DSL
end

Capybara.app_host = "http://www.wikipedia.org"
Capybara.default_driver = :selenium

RSpec.describe "Searching" do
  Steps "Result found" do
    Given "I am on wikipedia.com" do
      visit('/')
    end

    When "I enter \"Capybara\"" do
      fill_in "searchInput", :with => "Capybara"
    end

    When "click submit button" do
      find(".formBtn", match: :first).click
    end

    Then "I should see results" do
      expect(page).to have_content "Hydrochoerus hydrochaeris"
    end
  end

end

