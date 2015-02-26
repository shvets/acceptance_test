require 'steps/common_steps'

steps_for :search_with_drivers do
  include CommonSteps

  def initialize *params
    puts Capybara.current_driver

    super
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
