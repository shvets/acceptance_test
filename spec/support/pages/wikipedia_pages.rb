require 'rspec/expectations'
require 'acceptance_test/page_set'

require 'pages/main_page'

class WikipediaPages < PageSet
  include Capybara::DSL
  include RSpec::Matchers

  attr_reader :context

  def initialize session, smart_completion=true
    super session

    @main_page = MainPage.new self

    delegate_to_pages :main_page

    enable_smart_completion if smart_completion
  end

end

