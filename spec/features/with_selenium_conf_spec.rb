require File.expand_path(File.dirname(__FILE__) + '/features_spec_helper')

describe 'Google Search' do
  include_context "AcceptanceTest"

  before :all do
    selenium_config_file = "spec/features/selenium.yml"
    selenium_config_name = "test"

    acceptance_test.load_selenium_config selenium_config_file, selenium_config_name
  end

  before do
    puts "Using driver: #{Capybara.current_driver}."
  end

  it "uses selenium driver", driver: :selenium_remote do
    visit('/')

    fill_in "q", :with => "Capybara"

    find("#gbqfbw button").click

    all(:xpath, "//li[@class='g']/h3/a").each { |a| puts a[:href] }
  end
end