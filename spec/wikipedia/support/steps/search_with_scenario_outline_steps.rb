require 'csv'

# enable external source for gherkin

data_reader = lambda do |source_path|
  ext = File.extname(source_path)

  if ext == '.csv'
    CSV.read(File.expand_path(source_path))
  elsif ext == '.yml'
    YAML.load_file(File.expand_path(source_path))
  end
end

AcceptanceTest.instance.enable_external_source data_reader

steps_for :search_with_scenario_outline do

  step "I am within wikipedia.com" do
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
