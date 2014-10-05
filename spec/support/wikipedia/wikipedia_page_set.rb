require 'rspec/expectations'
require 'acceptance_test/page_set'

require 'wikipedia/main_page'

class WikipediaPageSet < PageSet
  include Capybara::DSL
  include RSpec::Matchers

  def initialize session=nil
    @session = session

    @main_page = MainPage.new self

    delegate_to_pages :main_page
  end

end