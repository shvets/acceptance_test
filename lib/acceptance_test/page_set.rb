require 'forwardable'

require 'acceptance_test/page'

class PageSet
  extend Forwardable

  attr_reader :pages
  attr_accessor :session

  def initialize session=nil
    @session = session
    @pages = []
  end

  def page
    session
  end

  def execute &code
    self.instance_eval &code
  end

  def delegate_to_pages *pages
    pages.each do |page|
      delegate_to_page page
    end
  end

  def delegate_to_page page
    @pages << page

    self.class.send :attr_reader, page

    self.class.def_delegators page, *page_methods(page)
  end

  def page_methods page
    clazz = self.send(page).class

    clazz.instance_methods - Page.instance_methods
  end

  private

  def camelize string
    string.split("_").each {|s| s.capitalize! }.join("")
  end

end
