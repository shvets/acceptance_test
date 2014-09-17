source "https://rubygems.org"

group :development do
  gem "gemspec_deps_gen"
  gem "gemcutter"
end

group :test do
  gem "mocha", :require => false
  gem "rspec"
end

group :acceptance_test do
  gem "activesupport", "~> 4.1.6"
  gem "capybara", "~> 2.4.1"
  gem "capybara-firebug", "~> 2.1.0"
  gem "selenium-webdriver", "~> 2.43.0"

  gem "capybara-webkit", "~> 1.3.0"

  # Note: You need to install qt:
  # Mac: brew install qt
  # Ubuntu: sudo apt-get install libqt4-dev libqtwebkit-dev
  # Debian: sudo apt-get install libqt4-dev
  # Fedora: yum install qt-webkit-devell

  # brew install phantomjs
  gem "poltergeist", "~> 1.5.1"
end

group :debug do
  gem "debugger-ruby_core_source"
  gem "ruby-debug-base19x", "0.11.30.pre12"
  gem "ruby-debug-ide", "0.4.17"
end

