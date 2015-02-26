steps_for :search_with_table do
  def initialize *params
    puts Capybara.current_driver

    super
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
