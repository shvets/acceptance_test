Given(/^I am within google\.com$/) do
  Capybara.app_host = "http://google.com"
end

Given /^I am on google\.com$/ do
  visit('/')
end

When /^I enter "([^"]*)"$/ do |term|
  fill_in('q',:with => term)
end

Then /^I should see css "([^"]*)"$/ do |css|
  expect(page).to have_css(css)
end

When(/^click submit button$/) do
   if Capybara.current_driver == :selenium
     find("#gbqfbw button").click
   else
     has_selector? ".gsfs .gssb_g span.ds input.lsb", :visible => true # wait for ajax to be finished

     button = first(".gsfs .gssb_g span.ds input.lsb")

     button.click
   end
end

Then(/^I should see results: "([^"]*)"$/) do |string|
  expect(page).to have_content(string)
end
