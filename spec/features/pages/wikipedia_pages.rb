require 'acceptance_test/page_set'

require 'features/pages/main_page'

class WikipediaPages < PageSet
  attr_reader :context

  def initialize session, context=nil
    super session

    @context = context

    @main_page = MainPage.new self

    delegate_to_pages :main_page

    TurnipHelper.instance.build_dynamic_steps self, context
  end
end
