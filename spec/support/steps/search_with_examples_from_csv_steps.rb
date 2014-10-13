steps_for :search_with_examples_from_csv do

  step "I am within wikipedia.com" do
    AcceptanceTest.instance.setup
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
