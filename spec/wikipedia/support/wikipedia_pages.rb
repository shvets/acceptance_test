require 'acceptance_test/page_set'

require 'pages'

class WikipediaPages < PageSet

  def initialize session
    super session

    @main_page = Pages::MainPage.new self

    delegate_to_pages :main_page
  end

end
