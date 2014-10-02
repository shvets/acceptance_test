require 'csv'
require 'yaml'

require 'acceptance_test'
require 'acceptance_test/gherkin_helper'

def setup_env
  data_reader = lambda {|source_path| CSV.read(File.expand_path(source_path)) }
  GherkinHelper.instance.enable_external_source data_reader

  config_name = File.expand_path("spec/acceptance_config.yml")
  config = HashWithIndifferentAccess.new(YAML.load_file(config_name))

  acceptance_test = AcceptanceTest.new
  acceptance_test.configure config
end

setup_env

module WikipediaSteps
  step "I am within wikipedia.com" do
    # Capybara.app_host = "http://wikipedia.com"
    # Capybara.default_driver = :selenium
  end

  step "I am on wikipedia.com" do
    visit('/')
  end

  step "I enter word :word" do |word|
    fill_in "searchInput", :with => word
  end

  step "I click submit button" do
    find(".formBtn", match: :first).click
  end

  step "I should see results: :content" do |text|
    expect(page).to have_content text
  end
end
