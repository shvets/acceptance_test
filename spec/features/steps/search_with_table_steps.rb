module SearchWithTableSteps

  step "I am within wikipedia.com" do
    self.class.include_context "SearchWithTableAcceptanceTest"
  end

  step "I am on wikipedia.com" do
    visit('/')
  end

  step "I have the following data:" do |table|
    @test_data = {}

    table.hashes.each do |hash|
      @test_data[hash['key']] = hash['value']
    end
  end

  step ":key should be :value" do |key, value|
    expect(@test_data[key]).to eq value
  end

  step "I should see <:key>" do |key|
    expect(page).to have_content @test_data[key]
  end

  # step "I enter word :word" do |word|
  #   fill_in "searchInput", :with => word
  # end

  step "I enter word <:key>" do |key|
    fill_in "searchInput", :with => @test_data[key]
  end

  step "I click submit button" do
    find(".formBtn", match: :first).click
  end

  step "I should see :text" do |text|
    expect(page).to have_content text
  end

end
