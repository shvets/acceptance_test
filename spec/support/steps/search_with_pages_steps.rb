require 'steps/common_steps'
require 'wikipedia_pages'

steps_for :search_with_pages do
  include CommonSteps

  attr_reader :page_set

  step "I am within wikipedia.com" do
    puts Capybara.current_driver

    @page_set = WikipediaPages.new(self)
  end

  step :visit_home_page, "I am on wikipedia.com"

  step :enter_word, "I enter word :word"

  # step :submit_request, "I submit request"

  # step "I am on wikipedia.com" do
  #   page_set.visit_home_page
  # end

  # step "I enter word :word" do |word|
  #   page_set.enter_word word
  # end

  # step "I submit request" do
  #   page_set.submit_request
  # end

end
