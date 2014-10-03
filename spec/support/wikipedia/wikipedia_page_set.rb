require 'acceptance_test/page_set'

require 'wikipedia/main_page'

class WikipediaPageSet < PageSet
  include Capybara::DSL

  def initialize session=nil
    @page = session

    @main_page = MainPage.new self

    delegate_to_pages :main_page
  end

end