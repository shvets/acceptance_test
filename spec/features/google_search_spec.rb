require File.expand_path(File.dirname(__FILE__) + '/features_spec_helper')

describe 'Google Search' do
  include_context "AcceptanceTest"

  before :all do
    acceptance_test.app_host = "http://www.google.com"
  end

  before do
    puts "Using driver: #{Capybara.current_driver}."
  end

  it "uses selenium driver", driver: :selenium, exclude: false do
    visit('/')

    fill_in "q", :with => "Capybara"

    find("#gbqfbw button").click

    all(:xpath, "//li[@class='g']/h3/a").each { |a| puts a[:href] }
  end

  it "uses webkit driver", driver: :webkit do
    visit('/')

    fill_in "q", :with => "Capybara"

    has_selector? ".gsfs .gssb_g span.ds input.lsb", :visible => true # wait for ajax to be finished

    button = first(".gsfs .gssb_g span.ds input.lsb")

    button.click

    all(:xpath, "//li[@class='g']/h3/a").each { |a| puts a[:href] }
  end

  it "uses poltergeist driver", driver: :poltergeist do
    pending
    visit('/')

    fill_in "q", :with => "Capybara"

    has_selector? ".gsfs .gssb_g span.ds input.lsb", :visible => true # wait for ajax to be finished

    button = first(".gsfs .gssb_g span.ds input.lsb")

    button.click

    all(:xpath, "//li[@class='g']/h3/a").each { |a| puts a[:href] }
  end
end