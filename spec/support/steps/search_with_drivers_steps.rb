require 'steps/common_steps'

steps_for :search_with_drivers do
  include CommonSteps

  step "I am within wikipedia.com" do
    AcceptanceTest.instance.setup page

    puts Capybara.current_driver
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

end
