source "https://rubygems.org"

group :development do
  gem "gemspec_deps_gen"
  gem "gemcutter"
  gem "capybara-webkit", "~> 1.4.1"
end

group :default do
  # Note: for capybara-webkit you need to install qt first:
  #
  # Mac: brew install qt
  # Ubuntu: sudo apt-get install libqt4-dev libqtwebkit-dev
  # Debian: sudo apt-get install libqt4-dev
  # Fedora: yum install qt-webkit-devell

  # for chrome support:
  # brew install chromedriver

  # Note: for poltergeist you have to install phantomjs first
  # brew install phantomjs

  gem "rspec"
  gem "turnip", "~> 1.2.4"
  gem "capybara", "~> 2.4.4"
  gem "selenium-webdriver", "~> 2.44.0"
  gem "capybara-firebug", "~> 2.1.0"
  gem "poltergeist", "~> 1.6.0"

  gem "turnip_formatter", "~> 0.3.3"
  gem "gnawrnip", "~> 0.3.2"

  gem "activesupport", "~> 4.2.0"

  gem "rspec-example_steps", "~> 3.0.2"
  gem "meta_methods", "~> 1.3.0"
end

group "test" do
  gem "cucumber"
end

# group :debug do
  # gem "debugger-ruby_core_source"
  # gem "ruby-debug-base19x", "0.11.30.pre12"
  # gem "ruby-debug-ide", "0.4.17"
# end

