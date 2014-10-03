require 'acceptance_test'
require 'yaml'

config_name = File.expand_path("spec/acceptance_config.yml")
config = config_name ? HashWithIndifferentAccess.new(YAML.load_file(config_name)) : {}

acceptance_test = AcceptanceTest.new false
acceptance_test.configure config

acceptance_test.create_shared_context "WikipediaAcceptanceTest"

puts "Application URL   : #{config[:webapp_url]}"  if config[:webapp_url]
puts "Selenium URL      : #{config[:selenium_url]}" if config[:selenium_url]
puts "Default Wait Time : #{Capybara.default_wait_time}"

RSpec.describe 'Wikipedia Search' do
  include_context "WikipediaAcceptanceTest"

  it "uses selenium driver", driver: :selenium do
    visit('/')

    fill_in "searchInput", :with => "Capybara"

    find(".formBtn", match: :first).click

    expect(page).to have_content "Hydrochoerus hydrochaeris"
  end
end