# AcceptanceTest - This gem simplifies configuration and run of acceptance tests

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

# Without selenium configuration

Your spec class:

```ruby
require 'acceptance_test'

describe 'Google Search' do

  include_context "AcceptanceTest"

  before :all do
    acceptance_test.app_host = "http://www.google.com"
  end

  it "uses selenium driver", driver: :selenium, exclude: false do
    visit('/')

    fill_in "q", :with => "Capybara"

    #save_and_open_page

    find("#gbqfbw button").click

    all(:xpath, "//li[@class='g']/h3/a").each { |a| puts a[:href] }
  end
end
```

# With selenium configuration

Your spec class:

```ruby
require 'acceptance_test'

describe 'Google Search' do

  include_context "AcceptanceTest"

  before :all do
    selenium_config_file = "spec/features/selenium.yml"
    selenium_config_name = "test"

    acceptance_test.load_selenium_config selenium_config_file, selenium_config_name
  end

  it "do something" do
    # ...
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request