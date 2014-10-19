require 'singleton'

class SharedContextBuilder
  include Singleton

  def build name, acceptance_test
    throw "rspec library is not available" unless defined? RSpec

    parent = self

    acceptance_test_lambda = lambda do
      parent.configure_rspec acceptance_test, self
    end

    RSpec.shared_context name do
      self.define_singleton_method(:include_context, acceptance_test_lambda)

      include_context
    end
  end

  def configure_rspec acceptance_test, object=nil
    # acceptance_test = self

    # if object
    #   if object.kind_of? RSpec::Core::Example
    #     rspec_conf = object.example_group.parent_groups.last
    #   else
    #     rspec_conf = object
    #   end
    # else
    #   rspec_conf = RSpec.configuration
    # end

    rspec_conf = object

    rspec_conf.around(:each) do |example|
      old_driver = Capybara.current_driver

      acceptance_test.setup(page, example.metadata)

      new_driver = Capybara.current_driver

      if old_driver != new_driver
        example.metadata.delete(old_driver)
        example.metadata[new_driver] = true
      end

      example.run

      acceptance_test.teardown(page, example.metadata, example.exception)
    end
  end

end