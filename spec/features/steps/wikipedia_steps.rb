module WikipediaSteps

  step "I am within wikipedia.com" do
    self.class.include_context "WikipediaAcceptanceTest"
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
