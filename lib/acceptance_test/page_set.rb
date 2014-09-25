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

  def self.delegate_to_pages *pages
    pages.each do |page|
      class_name = camelize(page.to_s)
      clazz = Object.const_get(class_name)

      attr_reader page

      def_delegators page, *(clazz.instance_methods - Page.instance_methods)
    end
  end

  private

  def self.camelize string
    string.split("_").each {|s| s.capitalize! }.join("")
  end
end
