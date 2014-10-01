require 'csv'
require 'yaml'

require 'acceptance_test'

require 'acceptance_test/gherkin_helper'

data_reader = lambda {|source_path| CSV.read(File.expand_path(source_path)) }
GherkinHelper.instance.enable_external_source data_reader

acceptance_test = nil

Before do |scenario|
  config_name = File.expand_path("spec/acceptance_config.yml")
  config = HashWithIndifferentAccess.new(YAML.load_file(config_name))

  acceptance_test = AcceptanceTest.new config

  acceptance_test.before acceptance_test.metadata_from_scenario(scenario)
end

After do |scenario|
  acceptance_test.after acceptance_test.metadata_from_scenario(scenario)

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

When(/^I click submit button$/) do
  find(".formBtn", match: :first).click
end

Then(/^I should see results: "([^"]*)"$/) do |results|
  expect(page).to have_content "Hydrochoerus hydrochaeris"
end

Then(/^I should see keyword results: (.*)$/) do |keyword|
  expect(page).to have_content keyword
end
