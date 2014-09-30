require 'acceptance_test'
require 'acceptance_test/cucumber_helper.rb'

require 'csv'

acceptance_test = nil

cucumber_helper = CucumberHelper.instance

def create_acceptance_test scenario, cucumber_helper
  source_path = cucumber_helper.source_path(scenario)

  keys = [["keyword"]]
  values = CSV.read(File.expand_path(source_path))

  cucumber_helper.set_outline_table scenario, keys, values

  config_name = File.expand_path("spec/acceptance_config.yml")
  config = HashWithIndifferentAccess.new(YAML.load_file(config_name))

  AcceptanceTest.new config
end

Before do |scenario|
  acceptance_test = create_acceptance_test(scenario, cucumber_helper)

  acceptance_test.before cucumber_helper.metadata_from_scenario(scenario)
end

After do |scenario|
  acceptance_test.after cucumber_helper.metadata_from_scenario(scenario)

  reset_session!
end

Given(/^I am within wikipedia\.com$/) do
  Capybara.app_host = "http://wikipedia.com"
end

Given /^I am on wikipedia\.com$/ do
  visit('/')
end

When /^I enter "([^"]*)"$/ do |_|
  fill_in "searchInput", :with => "Capybara"
end

When(/^I enter word (.*)$/) do |keyword|
  keyword = keyword.gsub("\"", '')

  fill_in "searchInput", :with => keyword
end

Then /^I should see css "([^"]*)"$/ do |css|
  expect(page).to have_css(css)
end

When(/^click submit button$/) do
  find(".formBtn", match: :first).click
end

Then(/^I should see results: "([^"]*)"$/) do |results|
  expect(page).to have_content "Hydrochoerus hydrochaeris"
end

Then(/^I should see keyword results: (.*)$/) do |keyword|
  expect(page).to have_content keyword
end