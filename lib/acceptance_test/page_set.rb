require 'forwardable'

require 'acceptance_test/page'

class PageSet
  extend Forwardable

  attr_accessor :session

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
    self.class.send :attr_reader, page

    clazz = self.send(page).class

    self.class.def_delegators page, *(clazz.instance_methods - Page.instance_methods)
    end

  private

  def camelize string
    string.split("_").each {|s| s.capitalize! }.join("")
  end
end
