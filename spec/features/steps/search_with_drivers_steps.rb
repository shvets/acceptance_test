steps_for :search_with_drivers do

  step "I am within wikipedia.com" do
    self.class.include_context "SearchWithDriversAcceptanceTest"
    p Capybara.default_driver
    p Capybara.current_driver
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

  step "I should see :text" do |text|
    expect(page).to have_content text
  end

end
