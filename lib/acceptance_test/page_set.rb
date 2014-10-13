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

  def enable_smart_completion context
    if context
      context.class.send(:define_method, :method_missing) do |method_name, *args, &block|
        page_set.send method_name, *args, &block
      end

      page_set = self

      pages.each do |page|
        page_methods(page).each do |method_name|
          method = page_set.method(method_name)

          context.class.step "I #{method_name.to_s.gsub('_', ' ')}" do |*args|
            page_set.send method_name, *args
          end

          context.class.step "#{method.to_s.gsub('_', ' ')}" do
            page_set.send method_name, *args
          end
        end
      end
    end
  end

  private

  def camelize string
    string.split("_").each {|s| s.capitalize! }.join("")
  end

end
