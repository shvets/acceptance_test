require 'forwardable'

require 'meta_methods/dsl_builder'
require 'acceptance_test/page'

class PageSet
  extend Forwardable

  attr_accessor :context
  attr_reader :pages, :input

  def initialize context
    @context = context
    @pages = []
    @input = {}
  end

  def session
    context.page
  end

  def execute &code
    MetaMethods::DslBuilder.instance.evaluate_dsl(self, nil, code)
  end

  def self.step title
    yield if block_given?
  end

  def step title
    values = []

    params = title.gsub(/:\w+/)

    params.each do |param|
      key = param.gsub(":", "").to_sym
      values << input[key] if input[key]
    end

    yield *values if block_given?
  end

  def delegate_to_pages *pages
    pages.each do |page|
      delegate_to_page page
    end
  end

  def delegate_to_page page
    pages << page

    self.class.send :attr_reader, page

    self.class.def_delegators page, *page_methods(page)
  end

  def page_methods page
    clazz = self.send(page).class

    clazz.instance_methods - Page.instance_methods
  end

  def enable_smart_completion
    context.class.send(:define_method, :method_missing) do |method_name, *args, &block|
      page_set.send method_name, *args, &block
    end

    page_set = self

    PageSet.class_eval do
      @page_set = page_set # class instance variable

      def self.page_set # access to class instance variable
        @page_set
      end
    end

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

  private

  def camelize string
    string.split("_").each {|s| s.capitalize! }.join("")
  end

end
