if defined? RSpec
  acceptance_test_lambda = lambda do
    attr_reader :acceptance_test

    before :all do
      @acceptance_test = AcceptanceTest.new ".", "tmp"
    end

    before do
      metadata = RSpec.current_example.metadata

      acceptance_test.before metadata
    end

    after do
      metadata = RSpec.current_example.metadata

      acceptance_test.after page, RSpec.current_example.exception, metadata

      self.reset_session!
    end
  end

  RSpec.shared_context "AcceptanceTest" do
    self.define_singleton_method(:include_context, acceptance_test_lambda)

    include_context
  end
end



