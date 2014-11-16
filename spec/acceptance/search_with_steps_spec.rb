require 'acceptance_test'
require 'acceptance_test/step_maker'

AcceptanceTest.instance.configure({webapp_url: 'http://www.wikipedia.org', timeout_in_seconds: 10})

RSpec.describe 'Wikipedia Search' do
  include Capybara::DSL
  include StepMaker

  before do |example|
    AcceptanceTest.instance.setup page, example.metadata

    puts "Using driver: #{Capybara.current_driver}."
    puts "Default wait time: #{Capybara.default_wait_time}."
  end

  after do |example|
    AcceptanceTest.instance.teardown page, example.metadata
  end

  it "executes default script" do
    visit('/')

    fill_in "searchInput", :with => "Capybara"

    find(".formBtn", match: :first).click

    expect(page).to have_content "Hydrochoerus hydrochaeris"
  end

  it "executes script with steps" do
    input[:name] = "wikipedia.com"

    step "I am within wikipedia.com"

    step "I am on wikipedia.com" do
      visit('/')
    end

    input[:word] = "Capybara"

    step "I enter word :word" do |word|
      fill_in "searchInput", :with => word
    end

    step "I submit request" do
      find(".formBtn", match: :first).click
    end

    input[:text] ="Hydrochoerus hydrochaeris"

    step "I should see :text" do |text|
      expect(page).to have_content text
    end
  end

end