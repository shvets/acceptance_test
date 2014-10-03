require 'csv'
require 'yaml'

require 'acceptance_test'

module WikipediaSteps
  attr_reader :acceptance_test

  def initialize
    @acceptance_test = AcceptanceTest.new
  end

  step "I am within wikipedia.com" do
    config_name = File.expand_path("spec/acceptance_config.yml")
    config = HashWithIndifferentAccess.new(YAML.load_file(config_name))

    acceptance_test.configure config
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
