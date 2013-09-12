# AcceptanceTestsSupport - This gem simplifies congiguration and run of acceptance tests

## Installation

Add this line to to your Gemfile:

```ruby
gem "acceptance_test"
```

And then execute:

```bash
$ bundle
```

## Usage

Your spec helper class:

```ruby
require 'acceptance_test'

selenium_config_file = "spec/features/selenium.yml"
selenium_config_name = 'test'

selenium_config = AcceptanceTestsSupport.load_selenium_config selenium_config_file, selenium_config_name

@@support = AcceptanceTestsSupport.new ".", selenium_config
```

and your spec:

```ruby
require File.expand_path(File.dirname(__FILE__) + '/features_spec_helper')

feature 'Google Search', %q{
    As a user of this service
    I want to enter a search text and get the relevant search results
    so that I can find the right answer
  } do

  include_context "AcceptanceTest", @@support

  before :all do
    @@support.app_host = "http://www.google.com"
  end

  scenario "uses selenium driver", driver: :selenium, exclude: false do
    visit('/')

    fill_in "q", :with => "Capybara"

    #save_and_open_page

    find("#gbqfbw button").click

    all(:xpath, "//li[@class='g']/h3/a").each { |a| puts a[:href] }
  end

end

```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request