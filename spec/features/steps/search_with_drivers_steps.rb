require 'features/steps/common_steps'

RSpec.configure do |config|
  config.before(:search_with_drivers => true) do |example|
    AcceptanceTest.instance.configure_rspec example
  end

  config.after(:search_with_drivers => true) do |_|
    reset_session!
  end
end

steps_for :search_with_drivers do
  include CommonSteps

  # before do
  #   AcceptanceTest.instance.configure_rspec rspec_root
  #
  # end
  #
  # after do
  #   puts "after"
  # end

  step "I am within wikipedia.com" do
    puts Capybara.current_driver

    AcceptanceTest.instance.set_app_host
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
