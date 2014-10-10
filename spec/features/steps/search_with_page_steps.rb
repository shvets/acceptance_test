require 'features/steps/common_steps'
require 'features/pages/wikipedia_pages'

RSpec.configure do |config|
  config.before(:search_with_page => true) do |example|
    AcceptanceTest.instance.configure_rspec example
  end

  config.after(:search_with_page => true) do |_|
    reset_session!
  end
end

steps_for :search_with_page do
  include CommonSteps

  attr_reader :page_set

  step "I am within wikipedia.com" do
    puts Capybara.current_driver

    AcceptanceTest.instance.set_app_host

    @page_set = WikipediaPages.new(page, self)
  end

  step :visit_home_page, "I am on wikipedia.com"

  step :enter_word, "I enter word :word"

  step :submit_request, "I click submit button"

  # step "I am on wikipedia.com" do
  #   page_set.visit_home_page
  # end

  # step "I enter word :word" do |word|
  #   page_set.enter_word word
  # end

  # step "I click submit button" do
  #   page_set.submit_request
  # end

end
