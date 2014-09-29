Given(/^I am within wikipedia\.com$/) do
  Capybara.app_host = "http://wikipedia.com"
end

Given /^I am on wikipedia\.com$/ do
  visit('/')
end

When /^I enter "([^"]*)"$/ do |term|
  fill_in "searchInput", :with => "Capybara"
end

Then /^I should see css "([^"]*)"$/ do |css|
  expect(page).to have_css(css)
end

When(/^click submit button$/) do
  find(".formBtn", match: :first).click
end

Then(/^I should see results: "([^"]*)"$/) do |string|
  expect(page).to have_content "Hydrochoerus hydrochaeris"
end
